#pragma once
#include "Engine Core\BasicDependencies.h"
#include "fiber_tasking_lib/global_args.h"
#include "fiber_tasking_lib/task_scheduler.h"

#define TASK_FUNCTION TASK_ENTRY_POINT
#define TASK FiberTaskingLib::Task
#define COUNTER std::shared_ptr<FiberTaskingLib::AtomicCounter>

namespace Scheduler{

	void Start(TASK);
	void Terminate();
}