#!/usr/bin/env nextflow


params.file1 = "${projectDir}/folder/file1.txt"
params.file2 = "${projectDir}/folder/file2.txt"
params.folder = "${projectDir}/folder"


process ls {
    input:
    path(folder)

    output:
    stdout

    script:
    """
    ls ${folder}
    """
}

process folderify {
    input:
    tuple val(meta), path(files)

    output:
    tuple val(meta), path("testdir/", type: "dir")

    script:
    """
    mkdir testdir
    cp ${files} testdir/
    """
}
workflow {
    test_ch = channel.of([[id:"test"], [file(params.file1), file(params.file2)]])
    // file1_ch = channel.fromPath(params.file1) | view

    // test_ch | view
    folder_ch = channel.fromPath(params.folder, checkIfExists: true, type: 'dir')

    // folder_ch | view

    ls(folder_ch)

    // ls.out | view

    folderify(test_ch)

    // folderify.out | view

    testfile = file(params.file1)
    // mkdir("copyfolder")
    dirtomake = file("copyfolder", type: "dir")
    dirtomake.mkdir()

    testfile.copyTo(dirtomake)
}
