#include "demangler.h"
#include "machodemangleexception.h"

using namespace redi;
/**
 class for using c++flt to demangle names. Uses Boost.Process from http://www.highscore.de/cpp/process/index.html
 */
Demangler::Demangler() : isRunning(false)
{
	init();
}

Demangler::~Demangler()
{
	if (child)
		child->close();
}

string Demangler::demangleName(const string& name) {
	if (isRunning){
		(*child) << name << endl;
		string line;
		child->out() >> line;
		return line;
	} else {
		throw MachODemangleException("Could not find/start process c++flt.");
	}
}

void Demangler::init() {
        // TODO: Search propertly c++filt
	std::string exec = "/usr/bin/c++filt";
	std::vector<std::string> args;
	args.push_back(exec);
    args.push_back("--strip-underscore");
    
    child.reset(new pstream(args));
	isRunning = child->is_open();
}