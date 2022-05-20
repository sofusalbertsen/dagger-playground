package main

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

dagger.#Plan & {
    actions: {
      hello: #AddHello & {
           dir: client.filesystem.".".read.contents
      }
      shellrun: #RunHello & {
          dir: client.filesystem.".".read.contents
      }  
    }
    client: filesystem: ".": {
        read: contents: dagger.#FS
        write: contents: actions.hello.result
    }
}


// Write a greeting to a file, and add it to a directory
#AddHello: {
    // The input directory
    dir: dagger.#FS

    // The name of the person to greet
    name: string | *"world"

    write: core.#WriteFile & {
        input: dir
        path: "hello-\(name).txt"
        contents: "hello, \(name)!"
    }

    // The directory with greeting message added
    result: write.output
}
#RunHello:{
    _pull: docker.#Pull & {
        source: "index.docker.io/debian"
    }
    _image: _pull.output
    dir: dagger.#FS
    filename: "hello.sh"
    bash.#Run & {
        input: _image
        script: {contents: "echo hello"}
    }
}