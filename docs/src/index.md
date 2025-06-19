```@meta
CurrentModule = Exodus
```

# Exodus
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is accessed via a pre-built julia linked library through julia ccalls.

Several helper utilies from [SEACAS](https://github.com/sandialabs/seacas) are also included to aid in using exodusII files in parallel environments and diffing files. 

