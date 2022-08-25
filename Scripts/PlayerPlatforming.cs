using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Controller2D))]
public class PlayerPlatforming : MonoBehaviour
{
    // Variables and Constants defined here
    // Movement variables
    public float moveSpeed = 6;
    float gravity = -50;
    float accelerationTimeInAir = .12f;
    float accelerationTimeOnGround = .05f;
    float velocityXSmoothing;
    float velocityYSmoothing;
    //bool isMoving;
    bool canMove;
    Vector3 velocity;

    bool isJumping;
    public float jumpVelocity = 300;
    public float shortJumpSpeed = .2f;

    int directionX;
    int directionY;

    // jump Cache and Coyote Time variables
    public float coyoteTime = .1f;
    bool jumpCached;
    public float jumpCacheTime = .1f;
    bool canCoyoteJump;
    bool coyoteTimerRunning = false;
    bool jumpCacheRunning = false;

    // Wall Jump vars
    public float wallJumpFriction = .8f;
    int wallJumpDir;
    public float wallJumpVelocity = 150f;
    bool isWallJumping;
    public float wallJumpAirControlLim = 5f;
    bool isWallSliding;

    // Basic Attacking
    public bool canDash;
    bool canEvade = true;
    public bool isDashing;
    public float dashSpeed;
    float dashTime;
    public bool isAttacking;
    public float attackTime;
    int aimDirectionX;
    int aimDirectionY;
    public float dashCooldown = 2.0f;
    public float evadeDelay = 0.5f;

    // References to components
    Controller2D controller;
    SpriteRenderer sprite;
    Animator anim;
    
    void Start()
    {
        controller = GetComponent<Controller2D>();
        anim = GetComponent<Animator>();
        sprite = GetComponent<SpriteRenderer>();
        canEvade = true;
    }

    
    IEnumerator CoyoteTimer(float coyoteTime)
    {
        canCoyoteJump = true;
        yield return new WaitForSeconds(coyoteTime);
        canCoyoteJump = false;
        yield return null;
        
    }


    IEnumerator JumpCache(float jumpCacheTime)
    {
        jumpCached = true;
        yield return new WaitForSeconds(jumpCacheTime);
        jumpCached = false;
        yield return null;
    }

    IEnumerator BasicAttack()
    {
        isAttacking = true;
        canDash = false;
        canMove = false;
        anim.SetTrigger("Attack1");
        //StartCoroutine(Dash(15, .05f));
        yield return new WaitForSeconds(attackTime);
        isAttacking = false;
        canMove = true;
        canDash = true;
        yield return null;
    }
    
    
    IEnumerator AirDash(float dashSpeed, float dashTime)
    {
        
        canDash = false;
        canMove = false;
        isDashing = true;
        velocity.x = 0;
        velocity.y = 0;
        yield return new WaitForSeconds(0.05f);
        //if (!controller.collisions.below)
        //{
            //if (aimDirectionY < 0.75f)
            //{
            //    velocity.x =  directionX;
            //}
            //else
            //{
        velocity.x = directionX;
        //    velocity.y =  aimDirectionY;
        velocity = velocity.normalized * dashSpeed;
        yield return new WaitForSeconds(dashTime);
        canMove = true;
        isDashing = false;
        yield return null;
            //}
        //}
    }
   
    IEnumerator EvadeDash(float dashSpeed, float dashTime)
    {

        canDash = false;
        canMove = false;
        canEvade = false;
        isDashing = true;
        velocity.x = 0;
        velocity.y = 0;
        yield return new WaitForSeconds(0.05f);
        velocity.x = directionX;
        velocity.y = 0.1f;
        velocity = velocity.normalized * dashSpeed;
        yield return new WaitForSeconds(dashTime);
        canMove = true;
        isDashing = false;
        yield return null;
        //}
        //}
    }

    IEnumerator EvadeTimer(float evadeDelay)
    {
        canEvade = false;
        yield return new WaitForSeconds(evadeDelay);
        canEvade = true;
        yield return null;
    }

    void AttackManager()
    {
        if (Input.GetButtonDown("Fire1") && controller.collisions.below && !isAttacking)
        {
            StartCoroutine(BasicAttack());
            
        }
    }

    void DashManager()
    {
        if (Input.GetButtonDown("Dash") && !isDashing && (!controller.collisions.above && !controller.collisions.below
            && !controller.collisions.right && !controller.collisions.left) && canDash)
        {
            StartCoroutine(AirDash(20f, 0.09f));
        }
        else if (Input.GetButtonDown("Dash") && !isDashing && controller.collisions.below && canEvade)
        {
            StartCoroutine(EvadeDash(20f, 0.09f));
            StartCoroutine(EvadeTimer(evadeDelay));
        }

    }

    public void TakeDamageTrigger()
    {
        StartCoroutine(HurtRecoil());
    }

    IEnumerator HurtRecoil()
    {
        canMove = false;
        canDash = false;
        // Iframes
        velocity.y = 2;
        velocity.x = directionX * -1;
        velocity = velocity * 8f;
        yield return new WaitForSeconds(0.5f);
        //velocity.y = 0.5f;
        //velocity.x = directionX * 3f;
        //yield return new WaitForSeconds(0.6f);
        canMove = true;
        yield return null;

    }

    void Update()
    {
        // If the controller is colliding with ground or ceiling, vertical velocity resets to 0.
        if (controller.collisions.above || controller.collisions.below)
        {
            velocity.y = 0;
        }
        if (controller.collisions.below)
        {
            isJumping = false;
            coyoteTimerRunning = false;
            jumpCacheRunning = false;
            isWallSliding = false;
            if (!isDashing)
            {
                canDash = true;
            }

        }
        // Resets wall jumping status on all collisions
        if (controller.collisions.above || controller.collisions.below || controller.collisions.right || controller.collisions.left)
        {
            isWallJumping = false;
        }

        // Input commands for horizontal movement controls
        Vector2 input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        // Checks direction
        DirectionFacing();
        // Jump Check
        if (!isAttacking)
        {
            Jump();
        }
        
        if (input.y > 0.2f)
        {
            aimDirectionY = 1;
        }
        if (input.y < 0.2f)
        {
            aimDirectionY = -1;
        }
        if (input.x > 0.2f)
        {
            aimDirectionX = 1;
        }
        if (input.x < 0.2f)
        {
            aimDirectionX = -1;
        }
        if(input.x == 0)
        {
            aimDirectionX = 0;
        }
        if(input.y == 0)
        {
            aimDirectionY = 0;
        }


        // Wall Jump Check
        WallJump();
        // Checks for attack inputs and runs coroutines
        AttackManager();
        DashManager();
        // horizontal velocity is equal to movespeed times input val
        float targetVelocityX = input.x * moveSpeed;
        if (controller.collisions.below is false)
        {
            // Prevents Wall Jump Spam
            if (isWallJumping)
            {
                velocity.x = Mathf.SmoothDamp(velocity.x, (moveSpeed * wallJumpDir), ref velocityXSmoothing, accelerationTimeInAir);
                if (velocity.y < wallJumpAirControlLim)
                {
                    isWallJumping = false;
                }
            }
            else
            // Standard Air Movement speed
            {
                if (canMove)
                {
                    velocity.x = Mathf.SmoothDamp(velocity.x, targetVelocityX, ref velocityXSmoothing, accelerationTimeInAir);
                }
            }
            
        }
        // Standard movement acceleration
        else if (controller.collisions.below && canMove)
        {
            velocity.x = Mathf.SmoothDamp(velocity.x, targetVelocityX, ref velocityXSmoothing, accelerationTimeOnGround);
            
        }


        // vertical velocity constantly adds gravity every second
        //velocity.y += gravity * Time.deltaTime;
        Gravity();
        // Move method called every frame
        controller.Move(velocity * Time.deltaTime);
        
        AnimationManager();
    }

    void Jump()
    {
        // If jump button is pressed and controller is grounded (collisions.below == True) the controller will jump

        if (Mathf.Sign(velocity.y) == -1 && isJumping is false && coyoteTimerRunning is false)
        {
            // Checks for Coyote Time
            coyoteTimerRunning = true;
            StartCoroutine(CoyoteTimer(coyoteTime));
        }

        // Jumping Mechanics including Coyote Time and Jump Caching
        if (Input.GetButtonDown("Jump"))
        {
            // Checks for Cached Jumps
            if (jumpCacheRunning is false && velocity.y < 0)
            {
                jumpCacheRunning = true;
                StartCoroutine(JumpCache(jumpCacheTime));
            }
            // Jumps if coyote or grounded
            if ((controller.collisions.below || canCoyoteJump) && !isAttacking)
            {
                anim.SetTrigger("Jump");
                velocity.y = jumpVelocity;
                canCoyoteJump = false;
                jumpCached = false;
                isJumping = true;

            }
        }
        // Jumps if cached
        if (jumpCached && controller.collisions.below)
        {
            
            velocity.y = jumpVelocity;
            jumpCached = false;
            isJumping = true;
        }

        // Variable jumping
        if (Input.GetButtonUp("Jump") && velocity.y > 0 && canDash)
        {
            velocity.y = shortJumpSpeed;
        }
    }

    void WallJump()
    {
        // If colliding with wall
        if((controller.collisions.right || controller.collisions.left) && !controller.collisions.below)
        {

            // Wall jumping direction
            if (controller.collisions.right)
            {
                wallJumpDir = -1;
            }
            else if (controller.collisions.left)
            {
                wallJumpDir = 1;
            }
            if (velocity.y < 0)
            {
                isWallSliding = true;
            }
            else
            {
                isWallSliding = false;
            }
            if (Input.GetButtonDown("Jump"))
            {
                velocity.x  = (wallJumpDir * wallJumpVelocity);
                // 3 is used to increase vertical jump velocity more than horizontal
                velocity.y = wallJumpVelocity + 3;
                isWallJumping = true;   
            }
        }
        else
        {
            isWallSliding = false;
        }
    }

    void Gravity()
    {
        if (!isDashing)
        {
            if (isWallSliding)
            {
                velocity.y += gravity * Time.deltaTime * 0.1f;
            }
            else
            {
                velocity.y += gravity * Time.deltaTime;
            }
        }

    }

    void DirectionFacing()
    {
        if (velocity.x > 0)
        {
            
            directionX = 1;
            sprite.flipX = false;
        }
        if (velocity.x < 0)
        {
            
            directionX = -1;
            sprite.flipX = true;
        }
        if (velocity.y > 0)
        {
            directionY = 1;
        }
        if (velocity.y < 0)
        {
            directionY = -1;
        }


    }

    void AnimationManager()
    {
        if (isJumping)
        {
            anim.SetTrigger("Jump"); 
            anim.SetBool("isGrounded", false);
        }
        if (controller.collisions.below)
        {
            anim.SetBool("isGrounded", true);
            anim.SetBool("isFalling", false);
        }
        if (velocity.y < -1 && !controller.collisions.below)
        {
            anim.SetBool("isFalling", true);
            anim.SetBool("isGrounded", false);
        }
        if ((-1 > velocity.x) || (velocity.x > 1))
        {
            anim.SetBool("isMoving", true);
        }
        if ((-1 < velocity.x) && (velocity.x < 1))
        {
            anim.SetBool("isMoving", false);
        }
    }



}
