# Delphi numeric range regular expression generator

## Summary
The following is a module translated to work with Delphi.  
https://github.com/voronind/range-regex  

## Usage

```Pascal
uses
  range_regex;


//…

  regex_str := regex_for_range(12, 34);
  // nenerates: '1[2-9]|2\d|3[0-4]'
```  
