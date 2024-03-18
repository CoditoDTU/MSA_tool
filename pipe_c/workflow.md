Workflow

This worflow file will contain a brief diagram with how  the modules for dpipeline will be connected in nextflow for easy implementation:

## Original diagram:

ObtainIDs.sh(Fasta seq) ---> .hmm file(a) + FamilyID(b)                      (1)
Getdb.sh((1b)) ---> .Fasta file with all sequences associated with Family ID (2)
filter.sh((2)) ---> Filetered sequences with an # length of filtering        (3)
clustering.sh((3)) ---> 0-11 clusters with $prefix_clu_seq.(1-11)            (4) 
Split.sh(4) ---> creates a 80/20 split for training/test by randomly removing clusters (5)   For future iterations not currently been worked on
Alignment.sh((5)+(1a))---> 0-11 MSA files based on each cluster or tr/tst              (6)
Drop.sh((6)) --->  Drop columns assigned as gaps from the MSAs                         (7) 

```mermaid
    flowchart LR
    input((Query Sequence))

    subgraph A[GetIDs.sh]
        direction TB
        id3[(interpro)] -->.hmmFile
        id3[(interpro)] -->ProteinID  
    end 
    
    subgraph B[GetDBs.sh]
        %% this is a comment
        direction TB
        id4[(interpro)] -->
        RawFasta 
    end
    subgraph C[filtering.sh]
        direction TB
        C1{Seq is longer than L?} -->  
        FiltFasta
    end
    subgraph D[Alignment.sh]
        direction TB
        D1[C2Fasta] -->
        D2[Add OG seq] -->
        D3[MSA]
    end
    
    cons(Conservation analysis)
    output((Dpipeline.csv file))

    input --> A 

    A--ProteinID--> B 
    B --> C
    C--> Clustering.sh 
    Clustering.sh --|11 clusters|--> D
    D --> cons --> output
```

 ## Pipeline_A: Cluster MSA where OG seq is

```markdown
→ ObtainIDs.sh (Fasta seq) ---> .hmm file(a) + FamilyID(b)                      (1)
→ Getdb.sh ((1b)) ---> .Fasta file with all sequences associated with Family ID (2)
→ filter.sh ((2)) ---> Filetered sequences with an # length of filtering        (3)
→ AddOgSeq ((3)) ---> Filtered fasta + og seq in first position                 (4)
→ clustering.sh ((4)) ---> 0-11 clusters with $prefix_clu_seq.(1-11)            (5)
→ Alignment.sh ((5)+(1a)) --> MSA from selected cluster*                        (6)
→ Cons_analysis ((6)) ---> List of conserved residues from OG sequence          (7)

```

```mermaid
    flowchart LR
    %% A = Getid
    %% B = GetDB
    %% C = Filter.sh
    %% D = Clustering with add og seq
    %% E = Alignment + selection of cluster with OG
    
    input((Query Sequence))
    %%A
    subgraph A[GetIDs.sh]
        direction TB
        id3[(interpro)] -->.hmmFile
        id3[(interpro)] -->ProteinID  
    end 
    %%B
    subgraph B[GetDBs.sh]
        direction TB
        id4[(interpro)] -->
        RawFasta 
    end
    %%C
    subgraph C[filtering.sh]
        direction TB
        C1{Seq is longer than L?} -->  
        FiltFasta
    end
    %%D
    subgraph D[Clustering.sh ]
        direction TB
        D1(Filt Fasta) -->
        AddOGSeq --> 
        Cluster 
    end

    %%E
    subgraph E[Alignment.sh]
        direction TB
        E1[C2Fasta] -->
        E2{Cluster has OG seq?} --|Yes|-->
        E3[MSA]
        E2{Cluster has OG seq?} --|No|--> Discard
        
    end
    
    cons(Conservation analysis)
    output((Pipe A .csv file))

    input --> A 
    A--ProteinID--> B 
    B --> C
    C ---> D
    D --|11 clusters|--> E
    A --|.hmm file|--> E
    E --|Cluster with OG MSA|--> cons --> output
```


## Pipeline_B: Full MSA for VAE training + Cons_analysis
```markdown
→ ObtainIDs.sh (Fasta seq) ---> .hmm file(a) + FamilyID(b)                      (1)
→ Getdb.sh ((1b)) ---> .Fasta file with all sequences associated with Family ID (2)
→ filter.sh ((2)) ---> Filetered sequences with an # length of filtering        (3)
→ AddOgSeq ((3)) ---> Filtered fasta + og seq in first position                 (4)
→ Alignment.sh ((4)+(1a)) ---> Big MSA file                                     (5)
→ Cons_analysis ((5)) ---> List of conserved residues from OG sequence          (6)
```


```mermaid
    flowchart LR
    %% A = Getid
    %% B = GetDB
    %% C = Filter.sh
    %% D = Alignment + Add ogseq
    
    input((Query Sequence))
    %%A
    subgraph A[GetIDs.sh]
        direction TB
        id3[(interpro)] -->.hmmFile
        id3[(interpro)] -->ProteinID  
    end 
    %%B
    subgraph B[GetDBs.sh]
        direction TB
        id4[(interpro)] -->
        RawFasta 
    end
    %%C
    subgraph C[filtering.sh]
        direction TB
        C1{Seq is longer than L?} -->  
        FiltFasta
    end
    

    %%D
    subgraph D[Alignment.sh]
        direction TB
        D2[Add OG seq] -->
        D3[MSA]
    end
    
    cons(Conservation analysis)
    output((Pipe B.csv file))

    input --> A 
    A--ProteinID--> B 
    B --> C
    C ---> D
    A --|.hmm file|--> D
    D --> cons --> output
```