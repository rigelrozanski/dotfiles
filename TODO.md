
 - :Notes custom vim help file for all my custom commands and thoughts
 - \fmt -> replace this function in vim with the one below
 - \db -> should debug the entire term, not only the word the cursor is under
 - \ldb -> debug with len
 - close NerdTreeTab if its the last split after a tab close
 - make `setlocal iskeyword+=.` ONLY apply during `\db`... etc
 - \fo should be updated to use the new parse library
 - :Fo MyFuncName          
     - like \fo except uses the provided function name and provides a better comment
 - \fnget -> creates a "get" function for the field which the cursor is under within a struct 
 - \fnset -> creates a "set" function for the field which the cursor is under within a struct 
 - \fngetset -> creates both above
 - :Fulfill MyStruct 
       -> if under an interface, should create a new object which fullfills 
          that interface with dummy functions. Add the following comment to the 
          header: 
                 "This struct fulfills the interface SomeInterface (DNETL)"
       -> for all cases also add the line right after the struct 
                 `var _ MyInterface = MyStruct{}`
 - ctrl-e -> create a better evaluation routine than the builtin vim
 - \ni    OR   :NewI OptionalNameForInterface
       -> if under a struct, creates an interface with all the existing functions on that struct
       -> will use OptionalNameForInterface if provided and then add the comment in the header: 
             "Companion interface of the struct MyStruct (DNETL)"
       -> otherwise will use the name MyStructI and not include the afformentioned comment
       -> create this interface definition above the struct definition 

^^^^^^^^^^^^^^^^ DONE ^^^^^^^^^^^^^^^^

SHARPEN VIM TOOLS:
 - \up   OR   :Update
       if the cursor is within an interface definition: 
          -> updates the interface with its relative-struct functions from one of 2 sources:
              1. if the comment above the struct contains the wording
                    "Companion interface of the struct MyStruct (DNETL)"
                 it will take it as "MyStruct". 
              2. the struct function will be taken as the struct name 
                 without the trailing "I" (aka MyStructI searches for MyStruct), 
       if the cursor is within a struct definition
          -> if the struct has within its header comment
                 "This struct fulfills the interface SomeInterface (DNETL)"
             then update that struct with any missing functions (as new dummy functions) 
             of SomeInterface
 - have all the golang functionality operate on the vim swap files and not the saved originals
 - figure out how to run gofmt from ftplugin file 
 - Improve \new
  - use the parse library
  - should be modified to send back the results (write directly and reload, causes issues)
  - new should deduplicate types in the input fields of the NewFunc
