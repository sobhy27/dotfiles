#! /bin/sh

rm -rf $PWD/tools/
mkdir $PWD/tools/

wget https://github.com/vadimcn/vscode-lldb/releases/download/v1.7.0/codelldb-x86_64-linux.vsix
mv $PWD/codelldb-x86_64-linux.vsix $PWD/tools
unzip $PWD/tools/codelldb-x86_64-linux.vsix -d $PWD/tools/codelldb
