lsof -t -i:4000,5001,8080,9000,9199 | xargs kill -9
