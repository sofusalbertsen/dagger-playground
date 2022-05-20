package main

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
)

dagger.#Plan & {
    actions: {
        _pull: core.#Pull & {source: "ubuntu"}
        hello: #AddHello & {
            dir: client.filesystem.".".read.contents
        }
        shellrun: #RunHello & {
            image: _pull.output
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
    image:image
    core.#Exec & {
        input: image
        args: ["ls"]
    }
}