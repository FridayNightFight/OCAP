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
	"bytes"
	"database/sql"
	"encoding/json"
	"html/template"
	"io"
	"io/ioutil"
	"log"
	"mime"
	"net/http"
	"os"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

var (
	db        *sql.DB
	options   *Options
	indexHTML []byte
)

// ClassGame Model type game in option file
// Example [TvT, tvt]
type ClassGame struct {
	Key  string `json:"key"`
	Name string `json:"name"`
}

// Options Model option file
type Options struct {
	Title       string      `json:"title"`
	Description string      `json:"description"`
	Author      string      `json:"author"`
	Language    string      `json:"language"`
	Version     string      `json:"version"`
	Listen      string      `json:"listen"`
	Secret      string      `json:"secret"`
	ClassesGame []ClassGame `json:"classes-game"`
}

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

func check(err error) {
	if err != nil {
		log.Println("error:", err)
	}
}

// OperationGet http header filter operation
func OperationGet(w http.ResponseWriter, r *http.Request) {
	op := OperationFilter{r.FormValue("name"), r.FormValue("older"), r.FormValue("newer"), r.FormValue("type")}
	ops, err := op.GetByFilter(db)
	check(err)

	b, err := json.Marshal(ops)
	check(err)
	w.Header().Set("Content-Type", "application/json")
	w.Write(b)
}

// OperationAdd http header add operation only for server
func OperationAdd(w http.ResponseWriter, r *http.Request) {
	// Check secret variable
	if options.Secret != "" && r.FormValue("secret") != options.Secret {
		log.Println(r.RemoteAddr, "invalid secret denied access")
		w.WriteHeader(http.StatusForbidden)
		return
	}

	// Parser new opertion
	op, err := NewOperation(r)
	check(err)

	// Compress operation
	err = op.SaveFileAsGZIP("static/data/", r)
	check(err)

	// Insert new line in db
	_, err = op.Insert(db)
	check(err)
}

// StaticHandler write index.html (buffer) or send static file
func StaticHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Path
		// if it is index.html
		if path == "/" {
			w.Write(indexHTML)
			return
		}
		// json data already compressed
		if strings.HasPrefix(path, "/data/") {
			r.URL.Path += ".gz"
			w.Header().Set("Content-Encoding", "gzip")
		}
		next.ServeHTTP(w, r)
	})
}

// CreatePage creates a page by templates. Subsequently does not generate it again
func CreatePage(path string, param interface{}) ([]byte, error) {
	var (
		tmpl *template.Template
		err  error
		buf  bytes.Buffer
	)
	if tmpl, err = template.ParseFiles("template/" + path); err != nil {
		return nil, err
	}
	if err = tmpl.Execute(&buf, param); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// LoggerRequest writes logs from incoming requests
func LoggerRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		res := ResponseWriter{w, 200}
		next.ServeHTTP(&res, r)
		log.Printf("%s %s %s %v \"%s\" \n", r.RemoteAddr, r.Proto, r.Method, res.status, r.URL)
	})
}

func init() {
	// Parsing option file
	var (
		blob []byte
		err  error
	)
	if blob, err = ioutil.ReadFile("option.json"); err != nil {
		panic(err)
	}
	if err = json.Unmarshal(blob, &options); err != nil {
		panic(err)
	}
}

func main() {
	var err error
	// Connecting logger file
	filelog, err := os.OpenFile("ocap.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		panic(err)
	}
	defer filelog.Close()
	wrt := io.MultiWriter(os.Stdout, filelog)
	log.SetOutput(wrt)
	log.Println("=== Starting server ===")

	// Create home page
	if indexHTML, err = CreatePage("index.html", options); err != nil {
		log.Println("error:", err)
		panic(err)
	}

	// Connect db
	if db, err = sql.Open("sqlite3", "data.db"); err != nil {
		log.Println("error:", err)
		panic(err)
	}
	defer db.Close()

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
	if err != nil {
		log.Println("error:", err)
		panic(err)
	}

	// Add exeption
	// not set header for json files (data/*.json.gz, map.json)
	mime.AddExtensionType(".json", "application/json")

	// Create router
	mux := http.NewServeMux()
	fs := http.FileServer(http.Dir("static"))
	mux.Handle("/", StaticHandler(fs))
	mux.HandleFunc("/api/v1/operations/add", OperationAdd)
	mux.HandleFunc("/api/v1/operations/get", OperationGet)

	http.ListenAndServe(options.Listen, LoggerRequest(mux))
}
