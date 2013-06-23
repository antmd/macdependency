#ifndef INTERNALFILE_H
#define INTERNALFILE_H

#include "macho_global.h"
#ifdef __OBJC__
#define OBJC_CLASS(name) @class name
#else
#define OBJC_CLASS(name) typedef struct objc_object name
#endif
typedef ptrdiff_t streamsize;

OBJC_CLASS(NSString);
OBJC_CLASS(NSFileHandle);

class InternalFile
{

public:
    static InternalFile* create(InternalFile* file);
    static InternalFile* create(const string& filename);
    void release();

    string getPath() const;
    string getName() const;
	string getTitle() const;
	unsigned long long getSize() const;
    bool seek(long long int position);
    streamsize read(char* buffer, streamsize size);
    long long int getPosition();
	time_t getLastModificationTime() const;

private:
    unsigned int counter;
    virtual ~InternalFile();
    InternalFile(const string& filename);
    NSString* _filename;
    NSFileHandle* file;
};

#endif // INTERNALFILE_H
