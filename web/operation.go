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
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"strconv"
	"time"
)

// Operation Model opearation table in db
type Operation struct {
	ID              int64   `json:"id"`
	WorldName       string  `json:"world_name"`
	MissionName     string  `json:"mission_name"`
	MissionDuration float64 `json:"mission_duration"`
	Filename        string  `json:"filename"`
	Date            string  `json:"date"`
	Class           string  `json:"type"`
}

// OperationFilter model for filter operations
type OperationFilter struct {
	MissionName string
	DateOlder   string
	DateNewer   string
	Class       string
}

// NewOperation by http request
func NewOperation(r *http.Request) (op Operation, err error) {
	op = Operation{}
	op.WorldName = r.FormValue("worldName")
	op.MissionName = r.FormValue("missionName")
	op.MissionDuration, err = strconv.ParseFloat(r.FormValue("missionDuration"), 64)
	op.Filename = r.FormValue("filename")
	op.Date = time.Now().Format("2006-01-02")
	op.Class = r.FormValue("type")
	return op, err
}

// SaveFileAsGZIP saves the file in compressed form on the server
func (o *Operation) SaveFileAsGZIP(dir string, r *http.Request) (err error) {
	// get reader file
	reader, _, err := r.FormFile("file")
	if err != nil {
		return err
	}
	defer reader.Close()

	// get writer file
	w, err := os.Create(path.Join(dir, o.Filename+".gz"))
	if err != nil {
		return err
	}
	defer w.Close()

	// copy file
	_, err = io.Copy(w, reader)
	if err != nil {
		return err
	}
	return nil
}

// Insert new row in db
func (o *Operation) Insert(db *sql.DB) (sql.Result, error) {
	return db.Exec(
		`insert into operations
			(world_name, mission_name, mission_duration, filename, date, type)
		values
			($1, $2, $3, $4, $5, $6)
		`,
		o.WorldName, o.MissionName, o.MissionDuration, o.Filename, o.Date, o.Class,
	)
}

// GetByFilter get all operations matching the filter
func (o *OperationFilter) GetByFilter(db *sql.DB) (operations []Operation, err error) {
	rows, err := db.Query(
		`select * from operations where
			mission_name LIKE "%" || $2 || "%" AND
			date <= $3 AND
			date >= $4 AND
			type LIKE "%" || $1`,
		o.MissionName,
		o.DateOlder,
		o.DateNewer,
		o.Class,
	)
	if err != nil {
		return nil, err
	}
	return executeAll(rows), nil
}

// GetAll execute all operation in array
func executeAll(rows *sql.Rows) (operations []Operation) {
	for rows.Next() {
		op := Operation{}
		err := rows.Scan(
			&op.ID,
			&op.WorldName,
			&op.MissionName,
			&op.MissionDuration,
			&op.Filename,
			&op.Date,
			&op.Class,
		)
		if err != nil {
			log.Println("error:", err)
			continue
		}
		operations = append(operations, op)
	}
	return operations
}
