part of battlecore;

class TargetHitResult
{
	bool hit;
	Character target;
	int damage;
	bool criticalHit;
	bool removeImageStatus;

	TargetHitResult({
	                bool this.hit: false,
	                Character this.target: null,
	                int this.damage: null,
	                bool this.criticalHit: false,
	                bool this.removeImageStatus: false
	                })
	{
	}
}