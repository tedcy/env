#pragma once
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

using namespace std;
using namespace std::chrono;

namespace test_log{
    template<typename T, typename... Args>
        std::unique_ptr<T> make_unique(Args&&... args) {
            return std::unique_ptr<T>(new T(std::forward<Args>(args)...));
        }
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
    };

    struct DataAny {
        DataAny(const char *value) : value_(string(value)), type_(Type::STRING) {
        }
        DataAny(const string &value) : value_(value), type_(Type::STRING) {
        }
        template <typename T>
            DataAny(T value, typename std::enable_if<std::is_integral<T>::value>::type* = 0) : value_(int64_t(value)), type_(Type::INT) {
            }
        string toString() const {
            if(type_ == Type::INT) {
                return to_string(value_.any_cast<int64_t>());
            }
            return value_.any_cast<string>();
        }
        private:
        Any value_;
        Type type_ = Type::UNKNOWN;
    };

    void log_debug(const vector<DataAny> &vs) {
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
    Timer() = default;
    Timer(const string& name) : name_(name + ":") {} 
    virtual ~Timer() { 
        auto dur = system_clock::now() - tp;
        cout << setiosflags(ios::left) << std::setw(20) << name_ << "Cost " << duration_cast<milliseconds>(dur).count() << " ms" << endl; 
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

int64_t TNOWMS() {
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

void perfStat(const string &filePrefix, const std::function<void()>& cb) {
    string filePath = "/tmp/" + filePrefix + "_stat.log";
    perfFork(cb, [&filePath](int pid) {
        stringstream ss;
        ss << "echo 0 > /proc/sys/kernel/nmi_watchdog && "
            "perf stat -e task-clock,context-switches,cpu-migrations,page-faults,cycles,"
            "instructions,branches,branch-misses,cache-references,cache-misses";
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
    perfFork(cb, [&filePath](int pid) {
        stringstream ss;
        ss << "echo 1 > /proc/sys/kernel/nmi_watchdog";
        return ss.str();
    });
}
void perfRecord(const string &filePrefix, const std::function<void()>& cb) {
    string filePath = "/tmp/" + filePrefix + "_record.perf.data";
    perfFork(cb, [&filePath](int pid) {
        stringstream ss;
        ss << "perf record -F 999 -g -e task-clock,context-switches,cpu-migrations,page-faults,cycles,"
            "instructions,branches,branch-misses,cache-references,cache-misses";
        ss << " -p " << pid << " -o " << filePath << " > /dev/null 2>&1";
        return ss.str();
    });
    cout << "Run any of this following" << endl;
    cout << "perf report -i " << filePath << endl;
    cout << "perf annotate -i " << filePath << endl;
}
}//namespace profile end
