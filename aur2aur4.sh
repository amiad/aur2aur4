#!/bin/bash

function help_script(){
	echo 'argument is missed'
	echo 'Usage:'
	echo './aur2aur4.sh -l "pack1 pack2 pack3"'
	echo 'or'
	echo './aur2aur4.sh -u username'
	exit
}

if [[ -z $1 ]]; then
	help_script
fi

while getopts ":l:u:" o; do
	case "${o}" in
		l)
			list=$OPTARG
			;;
		u)
			results=$(curl -s "https://aur.archlinux.org/rpc.php?type=msearch&arg=$OPTARG")
			list=$(echo $results | grep -Po '"Name":.*?[^\\],' | cut -d'"' -f4)
			
			if [[ ! $list ]]; then
				echo 'This user has no packages';
				exit;
			fi
			;;
		\?)
			help_script
			;;
	esac
done

mkdir -p aur4
cd aur4

for package in $list; do
	git clone ssh://aur@aur4.archlinux.org/$package.git
	
	prefix=$(echo $package | cut -c1-2)
	wget "https://aur.archlinux.org/packages/$prefix/$package/$package.tar.gz"
	tar xzf $package.tar.gz
	rm -rf $package.tar.gz
	
	cd $package
	mksrcinfo
	git add .
	git commit -m "Initial import"
	git push origin master
	
	cd ..
done

cd ..
echo "Import finished"
