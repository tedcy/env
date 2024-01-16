#pragma once
#define UNW_LOCAL_ONLY
#include <libunwind.h>

#include <iostream>
#include <sstream>
#include <fstream>
#include <deque>
#include <chrono>
#include <pthread.h>
#include <thread>
#include <string>
#include <system_error>
#include <type_traits>
#include <vector>
#include <mutex>
#include <iconv.h>
#include <assert.h>
#include <algorithm>
#include <iomanip>
#include <map>
#include <set>
#include <limits.h>
#include <memory>
#include <queue>
#include <cmath>
#include <functional>
#include <atomic>
#include <unordered_set>
#include <unordered_map>
#include <list>

using namespace std;
using namespace std::chrono;

namespace test_log{
    class Any {
        public:
            template <typename T>
                Any(const T &t) : base_(make_unique<Data<T>>(t)) {
                }
            Any& operator=(const Any &other) {
                if (this == &other) {
                    return *this;
                }
                base_ = unique_ptr<Base>(other.base_->clone());
                return *this;
            }
            Any(const Any &other) {
                *this = other;
            }
            template <typename T>
                T any_cast() const {
                    return dynamic_cast<Data<T>*>(base_.get())->value_;
                }
        private:
            class Base {
                public:
                    virtual ~Base() = default;
                    virtual Base* clone() const = 0;
            };
            template <typename T>
                class Data : public Base {
                    public:
                        Data(const T &t) : value_(t) {}
                        virtual Data* clone() const override {
                            return new Data{*this};
                        }
                        T value_;
                };
            unique_ptr<Base> base_;
    };

    enum class Type {
        UNKNOWN,
        STRING,
        INT,
        Double,
    };

    struct DataAny {
        DataAny(const char *value) : value_(string(value)), type_(Type::STRING) {
        }
        DataAny(const string &value) : value_(value), type_(Type::STRING) {
        }
        template <typename T>
        DataAny(T value, typename std::enable_if<std::is_integral<T>::value>::type* = 0) : value_(int64_t(value)), type_(Type::INT) {
        }
        template <typename T>
        DataAny(T value, typename std::enable_if<std::is_floating_point<T>::value>::type* = 0) : value_(double(value)), type_(Type::Double) {
        }
        string toString() const {
            if(type_ == Type::INT) {
                return to_string(value_.any_cast<int64_t>());
            }
            if(type_ == Type::Double) {
                return to_string(value_.any_cast<double>());
            }
            return value_.any_cast<string>();
        }
    private:
        Any value_;
        Type type_ = Type::UNKNOWN;
    };

    inline void log_debug(const vector<DataAny> &vs) {
        for (auto &v : vs) {
            cout << v.toString();
        }
        cout << endl;
    }

#define LOGVT(x) "|" , #x , "=" , x ,"|"
#define LOGV(x) "|" << #x << "=" << x << "|"
#ifdef LOG_TAG
    #define LDEBUG(...) test_log::log_debug({__VA_ARGS__})
#else
    #define LDEBUG(...)
#endif
}

struct Timer {
    static inline int w_ = 40;
    static void setW(int w) {
        w_ = w;
    }
    Timer() = default;
    Timer(const string& name) : name_(name + ":") {} 
    virtual ~Timer() { 
        auto dur = system_clock::now() - tp;
        cout << setiosflags(ios::left) << std::setw(w_) << name_ << "Cost " << duration_cast<milliseconds>(dur).count() << " ms" << endl; 
    } 
    string name_;
    system_clock::time_point tp = system_clock::now(); 
};
struct Bench : public Timer { 
    Bench() = default;
    Bench(const string& name) : Timer(name) {} 
    virtual ~Bench() { stop(); }
    void stop() { 
        auto dur = system_clock::now() - tp; 
        cout << setiosflags(ios::left) << std::setw(20) << name_ <<
            "Per op: " << duration_cast<nanoseconds>(dur).count() / std::max(val, 1L) << " ns" << endl; 
        auto perf = (double)val / duration_cast<milliseconds>(dur).count() / 10; 
        if (perf < 1) {
            cout << setiosflags(ios::left) << std::setw(20) << name_ <<
            "Performance: " << std::setprecision(3) << perf << " w/s" << endl; 
        }else {
            cout << setiosflags(ios::left) << std::setw(20) << name_ <<
            "Performance: " << perf << " w/s" << endl; 
        }
    } 
    Bench& operator++() { ++val; return *this; } 
    Bench& operator++(int) { ++val; return *this; } 
    Bench& add(long v) { val += v; return *this; } 
    long val = 0; 
};

inline int64_t TNOWMS() {
    std::chrono::milliseconds ms = std::chrono::duration_cast< std::chrono::milliseconds >(
        std::chrono::system_clock::now().time_since_epoch()
    );
    return ms.count();
}

#include <stdio.h>
#include <dlfcn.h>
#include <malloc.h>

#ifdef GPERF_TAG
#include <gperftools/heap-checker.h>
#endif

namespace profile {

struct CoutHelper {
    CoutHelper() {
        setvbuf(stdout, NULL, _IONBF, 0);
    }
};
struct MemoryHolder {
    static int64_t memoryUsed;
    static bool isStart;
    MemoryHolder() 
#ifdef GPERF_TAG
        : heap_checker_(__FUNCTION__) 
#endif
    {
        isStart = true;
        memoryUsed = 0;
    }
    void print() {
#ifdef GPERF_TAG
        HeapLeakChecker::Disabler disabler;
#endif
        isStart = false;
        cout << LOGV(memoryUsed) << endl;
        isStart = true;
    }
    ~MemoryHolder() {
#ifdef GPERF_TAG
        if (!heap_checker_.NoLeaks()) assert(NULL == "heap memory leak");
#endif
        isStart = false;
        if (memoryUsed) {
            cout << "leak" << LOGV(memoryUsed) << endl;
        }
        memoryUsed = 0;
    }
#ifdef GPERF_TAG
    HeapLeakChecker heap_checker_;
#endif
};

int64_t MemoryHolder::memoryUsed = 0;
bool MemoryHolder::isStart = false;
    
#ifdef GPERF_TAG
#include <gperftools/profiler.h>
#endif

struct CpuHolder {
    CpuHolder() {
#ifdef GPERF_TAG
        string profName = "/tmp/";
        profName += __FUNCTION__;
        profName += ".prof";
        ProfilerStart(profName.c_str());
#endif
    }
    ~CpuHolder() {
#ifdef GPERF_TAG
        ProfilerStop();
#endif
    }
};

static CoutHelper helper;
}//namespace profile end

#ifdef MEM_TAG
void* malloc(size_t sz) {
    static auto my_malloc = (void* (*)(size_t))dlsym(RTLD_NEXT, "malloc");
    auto ptr = my_malloc(sz);
    if (profile::MemoryHolder::isStart) {
        profile::MemoryHolder::memoryUsed += malloc_usable_size(ptr);
    }
    return ptr;
}
void free(void *ptr) {
    static auto my_free = (void (*)(void*))dlsym(RTLD_NEXT, "free");
    if (profile::MemoryHolder::isStart) {
        profile::MemoryHolder::memoryUsed -= malloc_usable_size(ptr);
    }
    return my_free(ptr);
}
#endif

namespace profile{
#include <unistd.h>
#include <stdio.h>
#include <signal.h>

inline void perfFork(const std::function<void()> &cb, const std::function<string(int)> &pid2Str) {
    static atomic<int> l = {0};
    assert(l++ == 0);
    int pid = getpid();
    int cpid = fork();
    string fileName;
    if (cpid == 0) {
        string command = pid2Str(pid);
        execl("/bin/sh", "sh", "-c", command.c_str(), nullptr);
    }else {
        setpgid(cpid, 0);
        sleep(1);
        cb();
        kill(-cpid, SIGINT);
        sleep(1);
    }
    l--;
}

inline void perfStat(const string &filePrefix, const std::function<void()>& cb) {
    cout << "perf stat " << filePrefix << " start" << endl;
    string filePath = "/tmp/" + filePrefix + "_stat.log";
    perfFork(cb, [&filePath](int pid) {
        stringstream ss;
        ss << "echo 0 > /proc/sys/kernel/nmi_watchdog && "
            "perf stat -e task-clock,context-switches,cpu-migrations,page-faults,cycles,"
            "instructions,branches,branch-misses,cache-references,cache-misses,L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses";
        ss << " -p " << pid << " > " << filePath << " 2>&1";
        return ss.str();
    });
    string result;
    fstream f(filePath);
    if (!f.is_open()) {
        cout << LOGV(filePath) << "open failed" << endl;
        return;
    }
    copy(std::istreambuf_iterator<char>(f),
        std::istreambuf_iterator<char>(),
        std::ostreambuf_iterator<char>(cout));
    perfFork(cb, [](int) {
        stringstream ss;
        ss << "echo 1 > /proc/sys/kernel/nmi_watchdog";
        return ss.str();
    });
    cout << "perf stat " << filePrefix << " end" << endl;
}

//event set empty to record all event, or specify one(cycles,instructions,branches,branch-misses,cache-references,cache-misses)
inline void perfRecord(const string &filePrefix, const std::function<void()>& cb, const string& event) {
    cout << "perf record " << filePrefix << LOGV(event) << "start" << endl;
    string filePath = "/tmp/" + filePrefix + "_record.perf.data";
    perfFork(cb, [&filePath, &event](int pid) {
        stringstream ss;
        if (event.empty()) {
            ss << "perf record -F 99 -g -e task-clock,context-switches,cpu-migrations,page-faults,cycles,"
                "instructions,branches,branch-misses,cache-references,cache-misses";
        }else {
            ss << "perf record -F 99 -g -e " << event;
        }
        ss << " -p " << pid << " -o " << filePath << " > /dev/null 2>&1";
        return ss.str();
    });
    cout << "perf stat " << filePrefix << LOGV(event) << "end" << endl;
    cout << "Run any of this following" << endl;
    cout << "perf report -i " << filePath << endl;
    cout << "perf annotate -i " << filePath << endl;
    cout << "If need flamegraph, specify event when call perfRecord" << endl;
    cout << "perf script -i " << filePath << 
        "|/root/FlameGraph/stackcollapse-perf.pl|/root/FlameGraph/flamegraph.pl > " << filePath << ".svg" << endl;
}
}//namespace profile end

#include <cxxabi.h>
inline std::string demangle(const char* mangled) {
    int status;
    std::unique_ptr<char[], void (*)(void*)> result(
            abi::__cxa_demangle(mangled, 0, 0, &status), std::free);
    return result.get() ? std::string(result.get()) : "error occurred";
}
template <typename T>
string getType() {
    return demangle(typeid(T).name());
}


#include <dlfcn.h>
#include <link.h>

inline size_t ConvertToVMA(size_t addr)
{
    Dl_info info;
    link_map* link_map;
    dladdr1((void*)addr,&info,(void**)&link_map,RTLD_DL_LINKMAP);
    return addr-link_map->l_addr;
}

inline std::string getBacktrace() {
    unw_cursor_t cursor;
    unw_context_t uc;
    unw_word_t ip, sp;
    char buf[8 * 1024];
    unw_word_t offset;
    unw_getcontext(&uc);            // store registers
    unw_init_local(&cursor, &uc);   // initialze with context

    std::string s("\n");

    while (unw_step(&cursor) > 0) {                         // unwind to older stack frame
        unw_get_reg(&cursor, UNW_REG_IP, &ip);              // read register, rip
        unw_get_reg(&cursor, UNW_REG_SP, &sp);              // read register, rbp
        unw_get_proc_name(&cursor, buf, sizeof(buf) - 1, &offset);     // get name and offset

        char spbuf[8 * 1024] = {};
        int len = 0;
        int status;
        char* demangled = abi::__cxa_demangle(buf, 0, 0, &status);
        size_t vma_ip = ConvertToVMA(ip);
        if (status == 0) {
            len = snprintf(spbuf, sizeof(spbuf), "0x%016lx <%s+0x%lx>\n", vma_ip, demangled, offset);   // x86_64, unw_word_t == uint64_t
            free(demangled);
        } else {
            len = snprintf(spbuf, sizeof(spbuf), "0x%016lx <%s+0x%lx>\n", vma_ip, buf, offset);   // x86_64, unw_word_t == uint64_t
        }

        if (len > 0 && len <= (int)sizeof(spbuf))
            s.append(spbuf, len);
    }

    return s;
}
