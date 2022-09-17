#include <iostream>
#include <sstream>
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

#ifdef MEM_GPERF_TAG
#include <gperftools/heap-checker.h>
#endif

struct MemoryUsedHolder {
    static int64_t memoryUsed;
    static bool isStart;
    MemoryUsedHolder() 
#ifdef MEM_GPERF_TAG
        : heap_checker_(__FUNCTION__) 
#endif
    {
        isStart = true;
        memoryUsed = 0;
    }
    void print() {
#ifdef MEM_GPERF_TAG
        HeapLeakChecker::Disabler disabler;
#endif
        isStart = false;
        cout << LOGV(memoryUsed) << endl;
        isStart = true;
    }
    ~MemoryUsedHolder() {
#ifdef MEM_GPERF_TAG
        if (!heap_checker_.NoLeaks()) assert(NULL == "heap memory leak");
#endif
        isStart = false;
        if (memoryUsed) {
            cout << "leak" << LOGV(memoryUsed) << endl;
        }
        memoryUsed = 0;
    }
#ifdef MEM_GPERF_TAG
    HeapLeakChecker heap_checker_;
#endif
};

int64_t MemoryUsedHolder::memoryUsed = 0;
bool MemoryUsedHolder::isStart = false;

#ifdef MEM_TAG
void* malloc(size_t sz) {
    static auto my_malloc = (void* (*)(size_t))dlsym(RTLD_NEXT, "malloc");
    auto ptr = my_malloc(sz);
    if (MemoryUsedHolder::isStart) {
        MemoryUsedHolder::memoryUsed += malloc_usable_size(ptr);
    }
    return ptr;
}
void free(void *ptr) {
    static auto my_free = (void (*)(void*))dlsym(RTLD_NEXT, "free");
    if (MemoryUsedHolder::isStart) {
        MemoryUsedHolder::memoryUsed -= malloc_usable_size(ptr);
    }
    return my_free(ptr);
}
#endif
