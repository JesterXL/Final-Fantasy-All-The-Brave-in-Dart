part of battlecore;

class HitResult
{
	bool hit = false;
	bool removeImageStatus = false;

	HitResult(this.hit, {bool removeImageStatus: false})
	{
		this.removeImageStatus = removeImageStatus;
	}
}