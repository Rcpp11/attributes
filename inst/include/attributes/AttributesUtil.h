#ifndef ATTRIBUTES_UTIL_H
#define ATTRIBUTES_UTIL_H

namespace attributes {

    // Utility class for getting file existence and last modified time
    class FileInfo {
    public:    
        explicit FileInfo(const std::string& path);
        
        std::string path() const { return path_; }
        bool exists() const { return exists_; }
        time_t lastModified() const { return lastModified_; }
        
    private:
        std::string path_;
        bool exists_;
        time_t lastModified_;
    };
    
    // Remove a file 
    bool removeFile(const std::string& path);
    
    // Recursively create a directory
    void createDirectory(const std::string& path); 
    
    // Known whitespace chars
    extern const char * const kWhitespaceChars; 
      
    // Query whether a character is whitespace
    bool isWhitespace(char ch); 
    
    // Trim a string
    void trimWhitespace(std::string* pStr);
    
    // Strip balanced quotes from around a string (assumes already trimmed)
    void stripQuotes(std::string* pStr); 
    
    // is the passed string quoted?
    bool isQuoted(const std::string& str);
    
    // show a warning message
    void showWarning(const std::string& msg);
    
} // namespace attributes

#endif
