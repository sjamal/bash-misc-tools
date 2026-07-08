# Data Processing Scripts

Scripts for data cross-referencing and analysis tasks.

## Scripts

### uniquePrograms.sh
Cross-references programs with course associations from CSV data.

**Key Features:**
- Matches program names across two files
- Appends course associations to matching programs
- Generates CSV output with associations
- Validates input files before processing

**Usage:**
```bash
./uniquePrograms.sh active_programs.txt current_courses.csv
```

**Input Files:**

`active_programs.txt` (one program per line):
```
Computer Science
Mathematics
Physics
```

`current_courses.csv` (program name in first column):
```
Program Name,Course Code,Course Title
Computer Science,CS101,Intro to CS
Computer Science,CS102,Data Structures
Mathematics,MATH101,Calculus I
```

**Output:**

`ProgsWithCourseAssocs.csv`:
```
Computer Science ,Computer Science
Computer Science ,Computer Science
Mathematics ,Mathematics
```

## Requirements

- Both input files must exist and be readable
- Standard utilities: grep, sed, awk, tr
- Write permissions in current directory

## Notes

- Searches are case-sensitive
- Program names are matched as substrings
- Each matching line generates one output line