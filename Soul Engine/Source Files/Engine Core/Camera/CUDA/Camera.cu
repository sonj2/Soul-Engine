#include "Engine Core/Camera/CUDA/Camera.cuh"

CUDA_FUNCTION Camera::Camera() :
	resolution(0,0),
	aspectRatio(0),
    position(0.0f,0.0f,0.0f),
	forward(0.0f,0.0f,1.0f),
	right(1.0f, 0.0f, 0.0f),
	fieldOfView(90.0f,65.0f),
	aperture(2*MILLIMETER),
	focalDistance(17*MILLIMETER),
	circularDistribution(false)
{	
}

CUDA_FUNCTION  Camera::~Camera(){

}

CUDA_FUNCTION void Camera::SetAspect(float newA){
	aspectRatio = newA;
}
CUDA_FUNCTION float Camera::GetAspect(){
	return aspectRatio;
}

CUDA_FUNCTION glm::vec3 Camera::Position() const {
    return position;
}

CUDA_FUNCTION void Camera::SetPosition(const glm::vec3& positionN) {
    position = positionN;
}

CUDA_FUNCTION void Camera::OffsetPosition(const glm::vec3& offset) {
    position += offset;
}

CUDA_FUNCTION glm::vec2 Camera::FieldOfView() const{
    return fieldOfView;
}
CUDA_FUNCTION void Camera::SetFieldOfView(glm::vec2 fieldOfView) {
    fieldOfView = fieldOfView;
}



CUDA_FUNCTION glm::vec3 Camera::Forward() const {
    return forward;
}
CUDA_FUNCTION void Camera::SetForward(glm::vec3& forN){
	forward = glm::normalize(forN);
}

CUDA_FUNCTION glm::vec3 Camera::Right() const {
    return right;
}
CUDA_FUNCTION void Camera::SetRight(glm::vec3& rightn) {
	right = normalize(rightn);
}

CUDA_FUNCTION void Camera::SetupRay(uint& index, Ray& ray,thrust::default_random_engine& rng, thrust::uniform_real_distribution<float>& uniformDistribution){

	//OPTIMIZED! int x = index - (y*resolution.y);

	// generate random jitter offsets for supersampled antialiasing

	//OPTIMIZED! float jitterValueX = uniformDistribution(rng) - 0.5f;
	//OPTIMIZED! float jitterValueY = uniformDistribution(rng) - 0.5f;

	// compute important values

	// compute point on image plane

	//OPTIMIZED! glm::vec3 middle = position + forward;
	//OPTIMIZED! glm::vec3 horizontal = right * tan(glm::radians(fieldOfView.x * 0.5f));
	//OPTIMIZED! glm::vec3 vertical = verticalAxis * tan((glm::radians(-fieldOfView.y * 0.5f))); 

	// move and resize image plane based on focalDistance
	// could also incorporate this into the original computations of the point

	//OPTIMIZED! glm::vec3 pointOnImagePlane = position + ((((position + forward) + (((2 * sx) - 1) *
	//	(right * tan(glm::radians(fieldOfView.x * 0.5f)))) + (((2 * sy) - 1) *
	//	(verticalAxis * tan((glm::radians(-fieldOfView.y * 0.5f)))))) - position) * focalDistance); // Important for depth of field!

	// now compute the point on the aperture (or lens)

	// generate random numbers for sampling a point on the aperture

	//OPTIMIZED! float random1 = uniformDistribution(rng);
	//OPTIMIZED! float random2 = uniformDistribution(rng);

	// sample a point on the circular aperture

	//OPTIMIZED! float apertureX = cos(angle) * distance;
	//OPTIMIZED! float apertureY = sin(angle) * distance;

	

	//OPTIMIZED!glm::vec3 apertureToImagePlane = (position + ((((position + forward) + (((2 * sx) - 1) *
	//	(right * tan(glm::radians(fieldOfView.x * 0.5f)))) + (((2 * sy) - 1) *
	//	(verticalAxis * tan((glm::radians(-fieldOfView.y * 0.5f)))))) - position) * focalDistance)) - aperturePoint;

	int y = int(index / resolution.y);

	glm::vec3 verticalAxis = normalize(cross(right, forward));

	float sx = ((uniformDistribution(rng) - 0.5f) + (index - (y*resolution.y))) / (resolution.x - 1);
	float sy = ((uniformDistribution(rng) - 0.5f) + y) / (resolution.y - 1);

	float angle = TWO_PI * uniformDistribution(rng);
	float distance = aperture * sqrt(uniformDistribution(rng));
	
	glm::vec3 aperturePoint = position + ((cos(angle) * distance) * right) + ((sin(angle) * distance) * verticalAxis);
	
	ray.origin = aperturePoint;

	glm::vec3 pointOnPlaneOneUnitAwayFromEye = 
		(position + forward) + (((2 * sx) - 1) * 
		(right * tan(glm::radians(fieldOfView.x * 0.5f)))) + (((2 * sy) - 1) * 
		(verticalAxis * tan((glm::radians(-fieldOfView.y * 0.5f)))));

	ray.direction = (position + ((pointOnPlaneOneUnitAwayFromEye-position) * focalDistance)) - aperturePoint;

}

CUDA_FUNCTION bool Camera::IsViewable() const{
	return !circularDistribution;
}
CUDA_FUNCTION void Camera::SetCircle(bool cir){
	circularDistribution = cir;
}
CUDA_FUNCTION void Camera::OffsetOrientation(float x, float y){
	right = glm::rotateX(right, glm::radians(x));
	forward = glm::rotateX(forward, glm::radians(x));

	right = glm::rotateY(right, glm::radians(y));
	forward = glm::rotateY(forward, glm::radians(y));
}