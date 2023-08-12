set -x

isTestMode=0
for arg in "$@"
do
    if [ "$arg" == "test" ]; then
        isTestMode=1
        break
    fi
done

if [ "$isTestMode" -eq 1 ]; then
    echo "Running in test mode"
else
    echo "Running in normal mode"
fi

ClangBuildAnalyzerPath="/root/env/ClangBuildAnalyzer/ClangBuildAnalyzer"
default_CFLAGS="-Wno-everything -ftime-trace -fno-access-control"
default_Clang14=${default_Clang14:-"/root/.vim/bundle/YouCompleteMe/clang+llvm-14.0.0-x86_64-unknown-linux-gnu/bin/clang++"}

if [ ! -d $ClangBuildAnalyzerPath ];then
    git clone https://github.com/aras-p/ClangBuildAnalyzer $ClangBuildAnalyzerPath
fi
ClangBuildAnalyzerBinPath="$ClangBuildAnalyzerPath/build/ClangBuildAnalyzer"
if [ ! -f $ClangBuildAnalyzerBinPath ];then
    mkdir -pv $ClangBuildAnalyzerPath/build
    cd $ClangBuildAnalyzerPath/build
    cd build
    cmake ..
    make -j
    cd -
fi

curPath=$(pwd)

if [ "$isTestMode" -eq 0 ]; then
    $ClangBuildAnalyzerBinPath --stop $curPath /dev/null
    $ClangBuildAnalyzerBinPath --start $curPath
fi

if [ -f "make_flags.config" ];then
    # 如果文件存在，查找 CFLAGS 关键词
    make_flags_CFLAGS=$(grep "CFLAGS" make_flags.config | sed 's/CFLAGS=//'| sed 's/CFLAGS =//'| tr -d '"')
    make_flags_other=$(grep -v "CFLAGS" make_flags.config)
fi
    
# 执行 make 命令并添加文件内容
make -j CFLAGS="$default_CFLAGS $make_flags_CFLAGS" CXX="$default_Clang14" $make_flags_other

if [ "$isTestMode" -eq 0 ]; then
    now=$(date "+%Y-%m-%d-%H-%M-%S")
    $ClangBuildAnalyzerBinPath --stop $curPath /tmp/ClangBuildAnalyzer.file_$now
    $ClangBuildAnalyzerBinPath --analyze /tmp/ClangBuildAnalyzer.file_$now > /tmp/ClangBuildAnalyzer.file_$now.result
fi