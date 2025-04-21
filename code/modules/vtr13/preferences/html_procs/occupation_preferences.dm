/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer"), widthPerColumn = 295, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(SSjob.occupations.len <= 0)
		HTML += "The job SSticker is not yet finished creating jobs, please try again later"
		HTML += "<center><a href='byond://?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		var/bypass = FALSE
		if (check_rights_for(user.client, R_ADMIN))
			bypass = TRUE

		for(var/datum/job/job in sortList(SSjob.occupations, GLOBAL_PROC_REF(cmp_job_display_asc)))

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='40%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='40%' align='center'>"
			var/rank = job.title

			var/displayed_rank = rank
			if(length(job.alt_titles) && (rank in alt_titles_preferences))
				displayed_rank = alt_titles_preferences[rank]

			lastJob = job
			if(is_banned_from(user.ckey, rank))
				HTML += "<font color=red><b>[rank]</b></font></td><td width='60%' align='center'><a href='byond://?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			//<font color=red>text</font> (Zamenil potomu chto slishkom rezhet glaza
			if(required_playtime_remaining && !bypass)
				HTML += "<font color=#290204><b>[rank]</b></font></td><td width='60%' align='center'><b><font color=#290204> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \]</font></b></td></tr>"
				continue
			if(!job.player_old_enough(user.client) && !bypass)
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=#290204><b>[rank]</b></font></td><td width='60%' align='center'><b><font color=#290204> \[IN [(available_in_days)] DAYS\]</font></b></td></tr>"
				continue
			if(!job.allowed_species.Find(pref_species.name) && !bypass)
				HTML += "<font color=#290204><b>[rank]</b></font></td><td width='60%' align='center'><b><font color=#290204> \[SPECIES RESTRICTED\]</font></b></td></tr>"
				continue
			if((pref_species.name == "Vampire" || pref_species.name == "Ghoul") && GLOB.vampire_factions_list.Find(job.exp_type_department) && vamp_faction?.name != job.exp_type_department) // && !bypass) - CHANGE BACK POST TESTING HEX
				HTML += "<font color=#290204><b>[rank]</b></font></td><td width='60%' align='center'><b><font color=#290204> \[FACTION RESTRICTED\]</font></b></td></tr>"
				continue
			if((job_preferences[SSjob.overflow_role] == JP_LOW) && (rank != SSjob.overflow_role) && !is_banned_from(user.ckey, SSjob.overflow_role))
				HTML += "<font color=orange><b>[rank]</b></font></td><td width='60%' align='center'></td></tr>"
				continue
			
			// TFN EDIT START: alt job titles
			var/rank_title_line = "[displayed_rank]"
			if(length(job.alt_titles) && (rank in GLOB.leader_positions))//Bold head jobs
				rank_title_line = "<b><a href='byond://?_src_=prefs;preference=job;task=alt_title;job_title=[job.title]'>[rank_title_line]</a></b>"
			else if(length(job.alt_titles))
				rank_title_line = "<a href='byond://?_src_=prefs;preference=job;task=alt_title;job_title=[job.title]'>[rank_title_line]</a>"
			else
				rank_title_line = "<span class='dark'>[rank]</span>"
			HTML += rank_title_line
			// TFN EDIT END

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			switch(job_preferences[job.title])
				if(JP_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = 4
					prefLowerLevel = 2
				if(JP_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = 1
					prefLowerLevel = 3
				if(JP_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = 2
					prefLowerLevel = 4
				else
					prefLevelLabel = "NEVER"
					prefLevelColor = "red"
					prefUpperLevel = 3
					prefLowerLevel = 1

			HTML += "<a class='white' href='byond://?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role)//Overflow is special
				if(job_preferences[SSjob.overflow_role] == JP_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"
		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message = "Be an [SSjob.overflow_role] if preferences unavailable"
		if(joblessrole == BERANDOMJOB)
			message = "Get random job if preferences unavailable"
		else if(joblessrole == RETURNTOLOBBY)
			message = "Return to lobby if preferences unavailable"
		HTML += "<center><br><a href='byond://?_src_=prefs;preference=job;task=random'>[message]</a></center>"
		HTML += "<center><a href='byond://?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)