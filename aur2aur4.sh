#!/bin/bash

function help_script(){
	echo 'Argument missing'
	echo 'Usage:'
	echo './aur2aur4.sh -a'
	echo 'or'
	echo './aur2aur4.sh -l "pack1 pack2 pack3"'
	echo 'or'
	echo './aur2aur4.sh -u username'
	exit
}

DEPS='git mksrcinfo wget'

if [[ -z $1 ]]; then
	help_script
fi

for command in $DEPS; do
	if [ ! $(command -v $command) ]; then
		echo "$command is missing. Please install it."
		exit
	fi
done

while getopts ":l:u:a:" o; do
	case "${o}" in
		l)
			list=$OPTARG
			;;
		u)
			results=$(wget -q -O- "https://aur.archlinux.org/rpc.php?type=msearch&arg=$OPTARG")
			list=$(echo $results | grep -Po '"Name":.*?[^\\],' | cut -d'"' -f4)

			if [[ ! $list ]]; then
				echo 'This user has no packages';
				exit;
			fi
			;;
		a)
			list=$(ssh aur@aur4.archlinux.org list-repos | grep '^*' | sed -e 's/^*//')
			;;
		\?)
			help_script
			;;
	esac
done

mkdir -p aur4

pushd aur4
for package in $list; do
	git clone ssh://aur@aur4.archlinux.org/$package.git

	prefix=$(echo $package | cut -c1-2)
	wget -q --show-progress "https://aur.archlinux.org/packages/$prefix/$package/$package.tar.gz"
	tar xzf $package.tar.gz
	rm -rf $package.tar.gz

	pushd $package
	mksrcinfo
	git add .
	git commit -m "Initial import"
	git push origin master
	popd
done
popd

echo "Import finished"
