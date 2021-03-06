#include "PhysicsEngine.h"
#include "CUDA/PhysicsEngine.cuh"

/*
 *    this just processes a scene with the CUDA physics engine.
 *    @param	scene	The scene.
 */

void PhysicsEngine::Process(const Scene* scene){

	ProcessScene(scene);
}
