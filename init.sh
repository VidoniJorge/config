# !/bin/bash
# initial config

# config vim
read -p "indique si desea configudar la conf incial de vim [s/n]" op

echo $op

if [ $op = 's' ]; then
  	mv ~/.vimrc ~/.vimrc.back 
  	ln -s  ~/config/vim/vimrc ~/.vimrc      

	mkdir ~/.vim

	ln -s ~/config/vim/colors ~/.vim/colors
fi

read -p "indique si desea configudar la conf de plugin [s/n]" op

if [ $op = "s" ]; then
	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

read -p "indique si desea instalar c [s/n]" op

if [ $op = "s" ]; then
	echo "apt install gcc"
	sudo apt install gcc
fi
