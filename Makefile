PWD := $(shell pwd)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
# FIND_IGNORE := .git # posts specs staff topic
fn := "MakeDate:"$(shell date "+%Y.%m.%d-%H:%M:%S")

# src only for pdf and zip, do not need for serve
SRC_MD :=  $(shell find $(PWD) ! -path "*.git/*" ! -path "*_book/*" -name "*.md")
SRC_SVG := $(shell find $(PWD) ! -path "*.git/*" ! -path "*_book/*" -path "*images/*" -name "*.txt")
SRC_SVG += images/git.cmd.outline.txt
SRC := $(SRC_MD) $(SRC_SVG) 

MAKE_SVG_INC := $(foreach f,$(SRC_SVG), $(shell if [ ! -d $(dir $(f))/plantuml ];then mkdir $(dir $(f))/plantuml; fi && echo $(dir $(f))plantuml/$(basename $(notdir $(f))).svg:$(f) > $(dir $(f))/plantuml/$(basename $(notdir $(f))).d) )
SVG := $(foreach f,$(SRC_SVG), $(dir $(f))plantuml/$(notdir $(f)) )
SVG := $(SVG:%.txt=%.svg)
DEP := $(SVG:%.svg=%.d)
TARGETS := plantuml.jar $(SVG) gitcourse.pdf gitcourse.zip 

all: $(TARGETS)
	@echo Done!

.PHONY: clean info

info:
	@echo "Target: "$(TARGETS)
	@echo "SRC: " $(subst $(PWD),.,$(SRC))
	@echo "DEP: " $(DEP)

clean:
	rm -rf book.pf gitcourse.pdf MakeDate* gitcourse.zip

plantuml.jar: 
	wget https://udomain.dl.sourceforge.net/project/plantuml/plantuml.jar

$(SVG):
	@echo $@
	@echo $^
	java -jar plantuml.jar -tsvg -o plantuml $<

include $(DEP)

gitcourse.pdf: $(SRC)
	@echo make pdf by gitbook
	gitbook pdf .
	mv book.pdf gitcourse.pdf

gitcourse.zip: $(SRC)
	# if [ -f MakeDate* ]; then rm MakeDate*; fi
	@echo zip all target files
	rm -f MakeDate*
	echo `date` > $(fn)
	zip -r gitcourse.zip exp* $(fn) gitcourse.pdf README.md outline.md refer.md