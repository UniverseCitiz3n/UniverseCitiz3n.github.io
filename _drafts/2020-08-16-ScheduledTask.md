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

![task]({{ site.url }}{{ site.baseurl }}/assets/images/posts/2020-08-16-ScheduledTask/taskcomponents.png)

* Triggers: Task Scheduler uses event or time-based triggers to know when to start a task. Every task can specify one or more triggers to start the task.
* Actions: These are the actions, the actual work, that is performed by the task. Every task can specify one or more actions to complete its work.
* Principals: Principals define the security context in which the task is run. For example, a principal might define a specific user or user group that can run the task.
* Settings: These are the settings that the Task Scheduler uses to run the task with respect to conditions that are external to the task itself. For example, these settings can specify the priority of the task with respect to other tasks, whether multiple instances of the task can be run, how the task is handled when the computer is in an idle condition, and other conditions.

> Note
By default, a task will be stopped 72 hours after it starts to run. You can change this by changing the ExecutionTimeLimit setting.

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
`Register-ScheduledTask` has the parameter `-User`, which allows you to run a task from a specified user account, of which **SYSTEM** can be one.
Besides that, you need to specify `-Trigger`, `-Action`, and `-Settings`.

I> Windows Sandbox is aware of the host's battery state, so while working on a laptop, you need to add `-AllowStartIfOnBatteries` to scheduled task settings.
Without that, you may wonder why the task is not running sometimes.

Tasks can be implemented as follows:

```powershell
$Trigger = New-ScheduledTaskTrigger -Once -At `$(Get-Date).AddMinutes(1)
$User = "SYSTEM"
$Action = New-ScheduledTaskAction -Execute "powershell.exe"
-Argument '-ex bypass -command "$SandboxTempFolder\$FileName.ps1"
-NoNewWindow -NonInteractive'

$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit "01:00"
-AllowStartIfOnBatteries

Register-ScheduledTask -TaskName "Install App" -Trigger $Trigger -User $User
-Action $Action -Settings $Settings -Force
```

To get more detailed information on **Task Scheduler** please refer to [documentation](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/Register-ScheduledTask?view=win10-ps).


See you in next! 😉 🧠

