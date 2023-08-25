set -x

isAnalyzerMode=0
isBearMode=0
isUseHead=0
lineCount=0
args_with_o_suffix=()
for arg in "$@"
do
    if [ "$arg" == "analyzer" ]; then
        isAnalyzerMode=1
    fi
    if [ "$arg" == "bear" ]; then
        isBearMode=1
    fi
    if [[ "$arg" == *.o ]]; then
        args_with_o_suffix+=("$arg")
    fi
    if [[ $arg == h* ]]; then
        lineCount=${arg#h}
        isUseHead=1
    fi
done

if [ "$isAnalyzerMode" -eq 1 ]; then
    echo "analyze mode enable"
fi
if [ "$isBearMode" -eq 1 ]; then
    echo "bear mode enable"
fi

default_CFLAGS="-ftime-trace -fno-access-control -Wno-unused-command-line-argument -Wno-unknown-warning-option"

#default_CFLAGS+=" -Wno-everything"
#taf warning
default_CFLAGS+=" -Wno-unused-lambda-capture"
default_CFLAGS+=" -Wno-inconsistent-missing-override"
default_CFLAGS+=" -Wno-braced-scalar-init"
default_CFLAGS+=" -Wno-mismatched-tags"

#brpc warning
default_CFLAGS+=" -Wno-header-guard"
default_CFLAGS+=" -Wno-overloaded-virtual"

#other
default_CFLAGS+=" -Wno-delete-non-abstract-non-virtual-dtor"

default_Clang14=${default_Clang14:-"/root/.vim/bundle/YouCompleteMe/clang+llvm-14.0.0-x86_64-unknown-linux-gnu/bin/clang++"}
curPath=$(pwd)

if [ "$isAnalyzerMode" -eq 1 ]; then
    ClangBuildAnalyzerPath="/root/env/clang_make/ClangBuildAnalyzer"
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
    $ClangBuildAnalyzerBinPath --stop $curPath /dev/null
    $ClangBuildAnalyzerBinPath --start $curPath
fi

if [ -f "make_flags.config" ];then
    # 如果文件存在，查找 CFLAGS 关键词
    make_flags_CFLAGS=$(grep "CFLAGS" make_flags.config | sed 's/CFLAGS=//'| sed 's/CFLAGS =//'| tr -d '"')
    make_flags_other=$(grep -v "CFLAGS" make_flags.config)
fi

# 执行 make 命令并添加文件内容
make_args=("${args_with_o_suffix[@]}" -j CFLAGS="$default_CFLAGS $make_flags_CFLAGS" CXX="$default_Clang14" $make_flags_other)
if [ "$isBearMode" -eq 1 ]; then
    bear make "${make_args[@]}" && cp compile_commands.json compile_commands.json_bk && compdb -p . list > /tmp/compile_commands.json && cp /tmp/compile_commands.json .
else
    if [ "$isUseHead" -eq 1 ]; then
        make "${make_args[@]}" 2>&1|head -n $lineCount
    else
        make "${make_args[@]}"
    fi
fi

if [ "$isAnalyzerMode" -eq 1 ]; then
    now=$(date "+%Y-%m-%d-%H-%M-%S")
    $ClangBuildAnalyzerBinPath --stop $curPath /tmp/ClangBuildAnalyzer.file_$now
    $ClangBuildAnalyzerBinPath --analyze /tmp/ClangBuildAnalyzer.file_$now > /tmp/ClangBuildAnalyzer.file_$now.result
fi
