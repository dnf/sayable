      *> One CLI request and its response, shared by the SAYABLE
      *> driver and the component programs it CALLs. Components read
      *> their arguments from here instead of the command line so the
      *> same code answers one-shot runs and --repl lines, and they
      *> append stdout lines (each ending in X"0A") to REQ-OUTPUT so
      *> the driver decides how to print them.
       01 SAYABLE-REQUEST.
          05 REQ-ARG-COUNT     PIC 9(4).
          05 REQ-ARG           PIC X(1024) OCCURS 256 TIMES.
          05 REQ-OUTPUT        PIC X(8192).
          05 REQ-OUTPUT-PTR    PIC 9(5).
          05 REQ-EXIT-CODE     PIC 9.
