#!/bin/sh
go get github.com/spf13/hugo 
$GOPATH/bin/hugo server --bind="::1" -b http://localhost:3031/ -w -D -v -t persona
