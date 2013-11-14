#ifndef ATTRIBUTES_PARSER_CommentState_H
#define ATTRIBUTES_PARSER_CommentState_H

namespace attributes{
  
    // Helper class for determining whether we are in a comment
    class CommentState {
    public:
        CommentState() : inComment_(false) {}
    private:
        // prohibit copying
        CommentState(const CommentState&);
        CommentState& operator=(const CommentState&); 
    public:
        bool inComment() const { return inComment_; }
        void submitLine(const std::string& line); 
        void reset() { inComment_ = false; }
    private:
        bool inComment_;
    };

}

#endif
