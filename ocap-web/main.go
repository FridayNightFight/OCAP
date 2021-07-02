// Copyright (C) 2020 Kuzmin Vladimir (aka Dell) (vovakyzmin@gmail.com)
//
// References to "this program" include all files, folders, and subfolders
// bundled with this license file.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

package main

import (
	"database/sql"
	"encoding/json"
	"html/template"
	"io"
	"log"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

var (
	db            *sql.DB
	textTemplates *template.Template
)

// ResponseWriter Access response to status
type ResponseWriter struct {
	http.ResponseWriter
	status int
}

// WriteHeader Save status code for log
func (res *ResponseWriter) WriteHeader(code int) {
	res.status = code
	res.ResponseWriter.WriteHeader(code)
}

// OperationGet http header filter operation
func OperationGet(w http.ResponseWriter, r *http.Request) {
	op := OperationFilter{
		MissionName: r.FormValue("name"),
		DateOlder:   r.FormValue("older"),
		DateNewer:   r.FormValue("newer"),
		Class:       r.FormValue("type"),
	}
	ops, err := op.GetByFilter(db)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(ops)
	if err != nil {
		log.Println(err.Error())
		return
	}
}

// OperationAdd http header add operation only for server
func OperationAdd(w http.ResponseWriter, r *http.Request) {
	// Check secret variable
	if C.Secret != "" && r.FormValue("secret") != C.Secret {
		log.Println(r.RemoteAddr, "invalid secret denied access")
		http.Error(w, "invalid secret denied access", http.StatusForbidden)
		return
	}

	// Parser new opertion
	op, err := NewOperation(r)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	// Compress operation
	err = op.SaveFileAsGZIP("static/data/", r)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	// Insert new line in db
	_, err = op.Insert(db)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
}

// StaticHandler write index.html (buffer) or send static file
func StaticHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// send home page
		if r.URL.Path == "/" {
			err := textTemplates.ExecuteTemplate(w, "index.html", C)
			if err != nil {
				http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
				log.Println(err.Error())
			}
			return
		}
		// Add Expiration cache 90 days (with code 404, the cache does not work [tested on Google Chrome])
		w.Header().Set("Cache-Control", "public, max-age=7776000")
		// disable directory listings
		if strings.HasSuffix(r.URL.Path, "/") {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		// json data already compressed
		if strings.HasPrefix(r.URL.Path, "/data/") {
			r.URL.Path += ".gz"
			w.Header().Set("Content-Encoding", "gzip")
			// Support mozilla
			w.Header().Set("Content-Type", "application/json")
		}
		next.ServeHTTP(w, r)
	})
}

// LoggerRequest writes logs from incoming requests
func LoggerRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		res := ResponseWriter{w, 200}
		next.ServeHTTP(&res, r)
		log.Printf("%s %s %s %v \"%s\" \n", r.RemoteAddr, r.Proto, r.Method, res.status, r.URL)
	})
}

func initTemplates() error {
	textTemplates = template.New("test")
	var err error
	textTemplates, err = textTemplates.ParseGlob(filepath.Join("template", "*"))
	if err != nil {
		return err
	}
	return nil
}

func initDB() error {
	var err error

	// Connect db
	if db, err = sql.Open("sqlite3", C.DB); err != nil {
		return err
	}

	// Create default database
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS operations (
		id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		world_name TEXT,
		mission_name TEXT,
		mission_duration INTEGER,
		filename TEXT,
		'date' TEXT ,
		'type' TEXT NOT NULL DEFAULT ''
	)`)
	return err
}

func main() {
	err := readConfig()
	if err != nil {
		panic(err.Error())
	}

	// Connecting logger file
	if C.Logger {
		loggingFile, err := os.OpenFile("ocap.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
		if err != nil {
			panic(err)
		}
		defer loggingFile.Close()
		log.SetOutput(io.MultiWriter(os.Stdout, loggingFile))
	}

	err = initTemplates()
	if err != nil {
		log.Panicln(err.Error())
	}

	err = initDB()
	if err != nil {
		log.Panicln(err.Error())
	}
	defer db.Close()

	log.Println("=== Starting server ===")

	// Add exeption
	// not set header for json files (map.json)
	mime.AddExtensionType(".json", "application/json")

	// Create router
	mux := http.NewServeMux()
	fs := http.FileServer(http.Dir("static"))
	mux.Handle("/", StaticHandler(fs))
	mux.HandleFunc("/api/v1/operations/add", OperationAdd)
	mux.HandleFunc("/api/v1/operations/get", OperationGet)

	http.ListenAndServe(C.Listen, LoggerRequest(mux))
}
