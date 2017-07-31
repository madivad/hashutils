# hashutils
## Hashing utilities for file and directory comparison
I am a HUGE fan of `hashdeep` (formerly `md5deep`), and use it for all hashing on file moves and verification and I generally hack together a series of steps when copying files from one location to another and verifcation of those files.

I have been procrastinating for a long time about writing my own tools and figured it was time to make this a reality.

At this point I will initially be looking to compile this mainly for linux and eventually OS X, and then (maybe) Windows. It would be good to include a windows version, but I haven't used Windows since the days of XP.

It's quite possible this will start out as a set of bash scripts and migrate to a compiled (C/C++) binary or possibly Python. I have a preference for a binary, however that's a much bigger learning curve for me. Let's see how we go.

## proposed features

    hashutils <dir1> <dir2>     
      compare files in <dir1> to files in <dir2>
        compare only files in <dir1> and do they exist in <dir2>
        compare directories and create report
          files in both directories
          files in dir1 only
          files in dir2 only
          files conflicting between directories
            these are filenames that exist in both directories but are not identical

    hashutils <path/to/file1> <path/to/file2>
      compare two files (not necessarily in the same directory)

    hashutils <path/to/file> <dir>
      does <file> appear in <dir>
        initial search by filename
          file exists and is the same (name,size,hash)
          file exists and is <new name>
          file does not exist
