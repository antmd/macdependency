#ifndef DEMANGLER_H
#define DEMANGLER_H

#include "macho_global.h"
#include <pstreams/pstream.h>
#include <memory>

class Demangler
{
public:
    Demangler();
    virtual ~Demangler();

    string demangleName(const string& name);
private:
    std::unique_ptr<redi::pstream> child;
	bool isRunning;
	
	void init();
private:
};

#endif // DEMANGLER_H
