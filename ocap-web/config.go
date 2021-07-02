package main

import (
	"strings"

	"github.com/spf13/viper"
)

// ClassGame Model type game in option file
// Example [TvT, tvt]
type ClassGame struct {
	Key  string `json:"key" yaml:"key"`
	Name string `json:"name" yaml:"name"`
}

// Options Model option file
type Options struct {
	Title       string      `json:"title" yaml:"title"`
	Description string      `json:"description" yaml:"description"`
	Author      string      `json:"author" yaml:"author"`
	Language    string      `json:"language" yaml:"language"`
	Version     string      `json:"version" yaml:"version"`
	Listen      string      `json:"listen" yaml:"listen"`
	Secret      string      `json:"secret" yaml:"secret"`
	Logger      bool        `json:"logger" yaml:"logger"`
	ClassesGame []ClassGame `json:"classes-game" yaml:"classes-game"`
	DB          string      `json:"db" yaml:"db"`
}

var C Options

func readConfig() error {
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.SetConfigName("option")
	viper.SetConfigType("json")
	viper.AddConfigPath("/etc/ocap")
	viper.AddConfigPath("$HOME/.ocap")
	viper.AddConfigPath(".")
	viper.SetDefault("db", "data.db")
	viper.SetDefault("listen", "0.0.0.0:5000")
	err := viper.ReadInConfig()
	if err != nil {
		return err
	}
	return viper.Unmarshal(&C)
}
