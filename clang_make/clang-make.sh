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

default_CFLAGS="-ftime-trace -Wno-unused-command-line-argument -Wno-unknown-warning-option"

#default_CFLAGS+=" -Wno-everything"
#taf warning
default_CFLAGS+=" -Wno-unused-lambda-capture"
default_CFLAGS+=" -Wno-inconsistent-missing-override"
default_CFLAGS+=" -Wno-braced-scalar-init"
default_CFLAGS+=" -Wno-mismatched-tags"
default_CFLAGS+=" -Wno-error=format-truncation"
default_CFLAGS+=" -Wno-error=unqualified-std-cast-call"

#brpc warning
default_CFLAGS+=" -Wno-header-guard"
default_CFLAGS+=" -Wno-overloaded-virtual"

#other
default_CFLAGS+=" -Wno-delete-non-abstract-non-virtual-dtor"

isDefaultClang14Set=0
if [ -n "${default_Clang14+x}" ]; then
    isDefaultClang14Set=1
fi
CLANG_MAKE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$CLANG_MAKE_DIR/glibc_check.sh"

default_Clang14=${default_Clang14:-"$CLANG_MAKE_DIR/cxx14/bin/clang++"}
default_Clang17=${default_Clang17:-"$CLANG_MAKE_DIR/cxx17/bin/clang++"}
default_Clang20=${default_Clang20:-"$CLANG_MAKE_DIR/cxx20/bin/clang++"}
MAIN_DIR=$(git rev-parse --show-toplevel)

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
    $ClangBuildAnalyzerBinPath --stop $MAIN_DIR /dev/null
    $ClangBuildAnalyzerBinPath --start $MAIN_DIR
fi

if [ -f "make_flags.config" ];then
    # 如果文件存在，查找 CFLAGS 关键词
    make_flags_CFLAGS=$(grep "CFLAGS" make_flags.config | sed 's/CFLAGS=//'| sed 's/CFLAGS =//'| tr -d '"')
    make_flags_other=$(grep -v "CFLAGS" make_flags.config)
fi

# 执行 make 命令并添加文件内容
if [ "$isDefaultClang14Set" -eq 0 ]; then
    effective_std=$(make "${args_with_o_suffix[@]}" -n -B -j16 CFLAGS="$default_CFLAGS $make_flags_CFLAGS" CXX="$default_Clang14" $make_flags_other 2>/dev/null | grep -oE -- '(^|[[:space:]])-?-std=[^[:space:]]+' | sed 's/^[[:space:]]*//' | tail -1)
    install_script="$CLANG_MAKE_DIR/cxx14/install.sh"
    selected_clang="$default_Clang14"
    required_glibc="2.27"
    if [[ "$effective_std" =~ ^-?-std=(c|gnu)\+\+(20|2a)$ ]]; then
        install_script="$CLANG_MAKE_DIR/cxx20/install.sh"
        selected_clang="$default_Clang20"
    elif [[ "$effective_std" =~ ^-?-std=(c|gnu)\+\+(17|1z)$ ]]; then
        install_script="$CLANG_MAKE_DIR/cxx17/install.sh"
        selected_clang="$default_Clang17"
    elif [[ "$effective_std" =~ ^-?-std=(c|gnu)\+\+(14|1y)$ ]]; then
        install_script="$CLANG_MAKE_DIR/cxx14/install.sh"
        selected_clang="$default_Clang14"
    fi
    if [ ! -x "$selected_clang" ]; then
        echo "clang-make: $effective_std requires $selected_clang, run $install_script first" >&2
        exit 1
    fi
    default_Clang14="$selected_clang"
    echo "clang-make effective std: ${effective_std:-manual}, CXX: $default_Clang14"
    clang_make_require_glibc "$required_glibc" "$effective_std"
else
    echo "clang-make effective std: manual, CXX: $default_Clang14"
fi
make_args=("${args_with_o_suffix[@]}" -j16 CFLAGS="$default_CFLAGS $make_flags_CFLAGS" CXX="$default_Clang14" $make_flags_other)
if [ "$isBearMode" -eq 1 ]; then
    bear -- make "${make_args[@]}" && cp compile_commands.json compile_commands.json_bk && compdb -p . list > /tmp/compile_commands.json && cp /tmp/compile_commands.json .
else
    if [ "$isUseHead" -eq 1 ]; then
        make "${make_args[@]}" 2>&1|head -n $lineCount
    else
        make "${make_args[@]}"
    fi
fi

if [ "$isAnalyzerMode" -eq 1 ]; then
    now=$(date "+%Y-%m-%d-%H-%M-%S")
    $ClangBuildAnalyzerBinPath --stop $MAIN_DIR /tmp/ClangBuildAnalyzer.file_$now
    $ClangBuildAnalyzerBinPath --analyze /tmp/ClangBuildAnalyzer.file_$now > /tmp/ClangBuildAnalyzer.file_$now.result
fi
