function extract
    set -l tmp_dir (mktemp -d --tmpdir=./)
    set -l archive_file_name (basename $argv[1])
    set -l archive_file_absolute_path (realpath (dirname $argv[1]))/$archive_file_name

    set -l suffix
    set -l command
    for line in \
        '.tar.gz  tar xzvf' \
        '.tgz     tar xzvf' \
        '.tar.xz  tar Jxvf' \
        '.zip     unzip' \
        '.lzh     lha e' \
        '.tar.bz2 tar xjvf' \
        '.tbz     tar xjvf' \
        '.tar.Z   tar zxvf' \
        '.gz      gzip -dc' \
        '.bz2     bzip2 -dc' \
        '.Z       uncompress' \
        '.tar     tar xvf'
        set -l suf (echo $line | cut -d' ' -f1)
        if string match -q "*$suf" $archive_file_name
            set suffix $suf
            set command (string replace -r '^[.a-zA-Z0-9]+ +' '' $line)
            break
        end
    end

    ln -s $archive_file_absolute_path $tmp_dir/$archive_file_name
    cd $tmp_dir > /dev/null 2>&1
    eval $command $archive_file_name && rm $archive_file_name
    if test $status -ne 0
        cd ..
        rm -rf $tmp_dir
        return 1
    end
    cd .. > /dev/null 2>&1

    set -l extracted_files (ls -A $tmp_dir)
    if test -d $tmp_dir/"$extracted_files" # This is satisfied when only one directory is extracted
        # If only one directory is extracted, move it to the current directory
        set -l extracted_file $extracted_files[1]
        set -e extracted_files
        if test -d ./"$extracted_file" # Check if the target directory already exists
            echo "cannot move directory to '$extracted_file': File exists" >&2
            echo "extracted file is at $tmp_dir/$extracted_file" >&2
            return 1
        else
            mv $tmp_dir/$extracted_file ./
            rm -rf $tmp_dir
        end
    else
        # When multiple files are extracted, rename the temp directory to the archive name without suffix
        set extract_name (dirname $archive_file_absolute_path)/(basename $archive_file_name $suffix)
        if test -f $extract_name
            echo "cannot move directory to '$extract_name': File exists" >&2
            echo "extracted files are in  $tmp_dir" >&2
        else
            echo "Moving $tmp_dir to $extract_name"
            mv $tmp_dir $extract_name
        end
    end
end
