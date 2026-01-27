# MP4-LRF File Organizer Script
# Checks for .MP4 files with accompanying .LRF files,
# creates a Proxy directory, moves LRF files there, and renames them to .MP4

def proxy [directory?: string] {
    # Use current directory if none specified
    let target_dir = if ($directory | is-empty) { "." } else { $directory }

    # Check if directory exists
    if not ($target_dir | path exists) {
        print $"Error: Directory '($target_dir)' does not exist"
        return
    }

    print $"Checking directory: ($target_dir)"

    # Find all MP4 files in the directory
    let mp4_files = ls $target_dir | where type == file and name =~ '\.mp4$|\.MP4$'

    if ($mp4_files | length) == 0 {
        print "No MP4 files found in directory"
        return
    }

    print $"Found ($mp4_files | length) MP4 files"

    # Check for corresponding LRF files
    mut lrf_files_to_process = []

    for mp4_file in $mp4_files {
        let base_name = $mp4_file.name | path parse | get stem
        let lrf_name = $"($base_name).lrf"
        let lrf_name_upper = $"($base_name).LRF"
        let lrf_path = $"($target_dir)/($lrf_name)"
        let lrf_path_upper = $"($target_dir)/($lrf_name_upper)"

        if ($lrf_path | path exists) {
            $lrf_files_to_process = ($lrf_files_to_process | append $lrf_path)
            print $"Found LRF file: ($lrf_name)"
        } else if ($lrf_path_upper | path exists) {
            $lrf_files_to_process = ($lrf_files_to_process | append $lrf_path_upper)
            print $"Found LRF file: ($lrf_name_upper)"
        }
    }

    if ($lrf_files_to_process | length) == 0 {
        print "No corresponding LRF files found"
        return
    }

    print $"Found ($lrf_files_to_process | length) LRF files to process"

    # Create Proxy directory
    let proxy_dir = $"($target_dir)/Proxy"
    if not ($proxy_dir | path exists) {
        mkdir $proxy_dir
        print $"Created Proxy directory: ($proxy_dir)"
    } else {
        print "Proxy directory already exists"
    }

    # Process each LRF file
    for lrf_file in $lrf_files_to_process {
        let file_name = $lrf_file | path parse
        let base_name = $file_name.stem
        let new_name = $"($base_name).mp4"
        let destination = $"($proxy_dir)/($new_name)"

        try {
            mv $lrf_file $destination
            print $"Moved and renamed: ($file_name.stem).($file_name.extension) -> Proxy/($new_name)"
        } catch {
            print $"Error processing file: ($lrf_file)"
        }
    }

    print "Processing complete!"
}
