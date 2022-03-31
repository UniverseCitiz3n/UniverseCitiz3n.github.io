---
title: Windows Task Scheduler. Automate stuff on chosen computer 🧑🏻‍💻
categories:

    - Powershell

tags:

    - Intune
    - Workstations
    - Windows 10
    - Powershell

excerpt: Learn about creating scheduled tasks using Powershell.

comments: true
toc: true
toc_label: Table of contents
---

# Intro

As and IT Pro sometimes you might get stuck while trying to run some application on endpoint or you want to execute some command at certain point of time or at desired conditions.
Well you guessed...just use built-in **Task Scheduler** and it will take care of everything 🧙🏻.

You can use the Task Scheduler to execute tasks such as starting an application, sending an email message, or showing a message box. Tasks can be scheduled to execute in response to these events, or triggers.

* When a specific system event occurs.
* At a specific time.
* At a specific time on a daily schedule.
* At a specific time on a weekly schedule.
* At a specific time on a monthly schedule.
* At a specific time on a monthly day-of-week schedule.
* When the computer enters an idle state.
* When the task is registered.
* When the system is booted.
* When a user logs on.
* When a Terminal Server session changes state.

# Basic theory

Let's talk more about this tasks.
A task is the scheduled work that the Task Scheduler service performs. A task is composed of different components, but a task must contain a trigger that the Task Scheduler uses to start the task and an action that describes what work the Task Scheduler will perform.

The following illustration shows the task components.

![task]({{ site.url }}/assets/images/posts/2020-08-16-ScheduledTask/taskcomponents.png)

* Triggers: Task Scheduler uses event or time-based triggers to know when to start a task. Every task can specify one or more triggers to start the task.
* Actions: These are the actions, the actual work, that is performed by the task. Every task can specify one or more actions to complete its work.
* Principals: Principals define the security context in which the task is run. For example, a principal might define a specific user or user group that can run the task.
* Settings: These are the settings that the Task Scheduler uses to run the task with respect to conditions that are external to the task itself. For example, these settings can specify the priority of the task with respect to other tasks, whether multiple instances of the task can be run, how the task is handled when the computer is in an idle condition, and other conditions.

> Note: By default, a task will be stopped 72 hours after it starts to run. You can change this by changing the ExecutionTimeLimit setting.

* Registration Information: This is administrative information that is gathered when the task is registered. For example, this information describes the author of the task, the date when the task was registered, an XML description of the task, and other information.
* Data: This is additional documentation about the task that is supplied by the author of the task. For example, this data may contain XML Help that can be used by users when they run the task. [source](https://docs.microsoft.com/en-gb/windows/win32/taskschd/tasks)

# Creating first task

To create task open `Powershell` terminal and type in:

```powershell
$Trigger = New-ScheduledTaskTrigger -Once -At $(Get-date).AddSeconds(30)
$Action = New-ScheduledTaskAction -Execute "notepad.exe"
Register-ScheduledTask -TaskName "First task - open notepad" -Trigger $Trigger -Action $Action
```

It will open `notepad` after 30 seconds delay.
From that point you can start building up your task.

## Trigger

As I mentioned earlier **task scheduler** provides you with wide range of time-based, event-based triggers.
For instance, to schedule task to start on Friday at 3 PM once every 3 weeks:

```powershell
$Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 3 -DaysOfWeek Friday -At 3pm
```

If you wish to schedule task to start at system boot:

```powershell
$Trigger = New-ScheduledTaskTrigger -AtStartup
```

Some tasks you might wish to end running after certain period of time.
To do that you need to specify `EndBoundary` value in a trigger.

```powershell
$Trigger = New-ScheduledTaskTrigger -Once -At $(Get-date).AddSeconds(30)
$AddHour = (Get-Date).AddHours(1).ToString('O')
$Trigger.EndBoundary = $AddHour
```

When you create the trigger with New-ScheduledTaskTrigger, the time you specify is converted and saved as a string in the trigger's StartBoundary property.
Be sure to convert your `EndBoundary` timezone 🕒.

## User

Use a scheduled task user to run a task under the security context of a specified account.

Using scheduled task allows you to execute actions with highest available privileges that is **SYSTEM** 🃏.
Alternatively you can specify service or any local user.
In case of users if you want to run task as other then currently logon user you need to provide credentials for that user.

```powershell
$User = "SYSTEM"
Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -User $User -Action $Action -Settings $Settings -Force
```

To execute as other user you must use `-Password` parameter.

## Action

The New-ScheduledTaskAction cmdlet creates an object that contains the definition of a scheduled task action. A scheduled task action represents a command that a task executes when Task Scheduler runs the task. You can use a task action definition to register a new scheduled task or update an existing task registration.

A task can have a single action or a maximum of 32 actions. When you specify multiple actions, Task Scheduler executes the actions sequentially. The Task Scheduler service controls tasks activation, and it hosts the tasks that it starts.

Creating action which runs `Powershell` can be implemented as follows:

```powershell
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ex bypass -command "notepad.exe" -NoNewWindow -NonInteractive'
```

## Settings

Finally, `New-ScheduledTaskSettingsSet` allows you to tweak your automation so that you can be sure its maximum execution time is limited

```powershell
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1)
```

...schedule task restart...

```powershell
-RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 15)
```

...or if device is a laptop...

```powershell
-AllowStartIfOnBatteries
```

...and combined with `EndBoundary`...

```powershell
-DeleteExpiredTaskAfter (New-TimeSpan -Seconds 5)
```

...go on and checkout [all available settings](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasksettingsset?view=win10-ps) to make sure your task is robust 💪🏼!

# Use case - Run Dell Command Update

Now that you know your way around `Scheduled Tasks` lets use it to make some magic ✨.

If you are using Dell laptop you might know this neat soft called **Dell Command | Update**.
It allows you to scan, download and install all model specific drivers for device using GUI or cmd-line.
You can `Enter-PSSession` to device, go to `dcu.exe` location and run app to check for updates.

But you can also create task on target device and once it's there you will just need to **start it**.
Check it out:

```powershell
$Trigger = New-ScheduledTaskTrigger -Once -At $(Get-Date).AddMinutes(1)
$AddHour = (Get-Date).AddHours(1).ToUniversalTime().ToString('%yy-%M-%dT%H:%m:%s.000Z')
$Trigger.EndBoundary = $AddHour
$User = "SYSTEM"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "Start-Process 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe' -ArgumentList '/applyUpdates -silent -outputLog=`"C:\Temp\DellCommandUpdate.log`"' -Wait"
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit "01:00" -AllowStartIfOnBatteries
$Task = New-ScheduledTask -Action $Actions -Trigger $Trigger -Settings $Settings -Description 'Update process'

Register-ScheduledTask -TaskName "DCU Update" -InputObject $Task -User $User -Force
```

> Note: DCU itself allows you to schedule update check and installation settings.
So choose best fitted option for your environment 😉.

# Summary

`Task Scheduler` is a great tool in automating and allows you execute some actions in different way than just `Invoke-Command`.
Because I've used `Powershell` I can save such script as an `.ps1` file and upload it to Intune.
It will then be deployed to assigned group of devices!

As always, endless possibilities and...
See you in next! 😉 🧠
