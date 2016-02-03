
xcaction () {
	local action=$1
	local project=$2
	local scheme=$3
	local other_args=$4

	local xcode_command="set -o pipefail && "

	# Prevent Xcode from buffering piped output.
	xcode_command+="env NSUnbufferedIO=YES "

	# The actual xcodebuild command.
	xcode_command+="xcodebuild $action -project '$project' -scheme '$scheme'"

	if [[ $other_args ]]; then
		xcode_command+=" $other_args"
	fi

	# Pipe the output through xcpretty if it is installed.
	if hash xcpretty 2>/dev/null; then
		xcode_command+=" | xcpretty --color --simple"
	fi

	eval $xcode_command
	local xcode_status=$?

	if [[ "$xcode_status" -ne "0" ]]; then
		exit $xcode_status
	fi
}

xctest () {
	local project=$1
	local scheme=$2
	local destination=$3
	local other_args=$4

	local test_command="set -o pipefail && "

	# Prevent Xcode from buffering piped output.
	xcode_command+="env NSUnbufferedIO=YES "

	test_command+="xcodebuild test -project '$project' -scheme '$scheme' -destination '$destination'"

	if [[ $other_args ]]; then
		xcode_command+=" $other_args"
	fi

	# Pipe the output through xcpretty if it is installed.
	if hash xcpretty 2>/dev/null; then
		test_command+=" | xcpretty --color --test"
	fi

	# Run the test test command.
	eval $test_command
}
