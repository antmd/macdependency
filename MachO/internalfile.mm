#include "internalfile.h"
#include "machoexception.h"
#include <sstream>
#import <Foundation/Foundation.h>


// use reference counting to reuse files for all used architectures
/* static */
InternalFile* InternalFile::create(InternalFile* file) {
    file->counter++;
    return file;
}

/* static */
InternalFile* InternalFile::create(const string& filename) {
	return new InternalFile(filename);
}

void InternalFile::release() {
    counter--;
    if (counter < 1) {
        delete this;
    }
}

InternalFile::InternalFile(const string& filename) :
	counter(1)
{
    _filename = [ NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding ];
	// open file handle
    NSError* error = nil;
    file = [ NSFileHandle fileHandleForReadingFromURL:[ NSURL fileURLWithPath:_filename ] error:&error ];
	if (error !=nil) {
		ostringstream error;
		error << "Couldn't open file '" << filename << "'.";
		throw MachOException(error.str());
	}
}

// destructor is private since we use reference counting mechanism
InternalFile::~InternalFile()  {
    [ file closeFile ];
}

string InternalFile::getPath() const {
	return [[ _filename stringByDeletingLastPathComponent ] cStringUsingEncoding:NSUTF8StringEncoding];

}

/* returns whole filename (including path)*/
string InternalFile::getName() const {
	
	// try to canonicalize path
	return [_filename cStringUsingEncoding:NSUTF8StringEncoding];
}

/* returns filename without path */
string InternalFile::getTitle() const {
	return [[ _filename lastPathComponent ] cStringUsingEncoding:NSUTF8StringEncoding];
}

unsigned long long InternalFile::getSize() const {
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: _filename error: NULL];
    UInt32 result = [attrs[NSFileSize] unsignedIntegerValue];
	return result;
}

bool InternalFile::seek(long long int position) {
    [ file seekToFileOffset:position ];
	return true;
}

streamsize InternalFile::read(char* buffer, streamsize size) {
    NSData* data = [ file readDataOfLength:size ];
    streamsize gcount = [ data length ];
    memcpy(buffer, [data bytes], gcount );
    return gcount;
}

long long int InternalFile::getPosition() {
	return [ file offsetInFile ];
 }

time_t InternalFile::getLastModificationTime() const {
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: _filename error: NULL];
    NSDate* result = attrs[NSFileModificationDate];
	return [result timeIntervalSince1970 ];
}
