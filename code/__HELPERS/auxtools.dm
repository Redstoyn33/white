/// Macro for getting the auxtools library file
#define AUXMOS (world.system_type == MS_WINDOWS ? "auxtools/auxmos.dll" : __detect_auxtools("auxmos"))
#define AUXLUA (world.system_type == MS_WINDOWS ? "auxtools/auxlua.dll" : __detect_auxtools("auxlua"))

/proc/__detect_auxtools(library)
	if(IsAdminAdvancedProcCall())
		return
	if (fexists("./lib[library].so"))
		return "./lib[library].so"
	else if (fexists("./auxtools/[library].so"))
		return "./auxtools/[library].so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"
	else
		CRASH("Could not find lib[library].so")
