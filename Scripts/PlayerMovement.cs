using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement Settings")]
    public float baseWalkSpeed;
    [Range(1, 3)]
    public float maxAccelerationMultiplier;
    [Range(0, 5)]
    public float accelerationRate;
    [Range(0, 5)]
    public float deaccelerationRate;
    public float gravityForce;
    public float staticGravityStrength;
    public float jumpStrength;

    [Header("Crouch Settings")]
    public float maxYScale;
    public float minYScale;
    public float crouchRate;
    public float standRate;
    public float crouchSpeedDivider;

    [Header("Directional Adjustment")]
    [Range(1, 2)]
    public float playerForwardDiagonalWalkSpeedDivider;
    [Range(1, 2)]
    public float playerSideWalkSpeedDivider;
    [Range(1, 2)]
    public float playerBackDiagonalWalkSpeedDivider;
    [Range(1, 2)]
    public float playerBackWalkSpeedDivider;

    [Header("Tolerances")]
    public float moveCheckTolerance;
    public float playerStandCheckTolerance;

    [Header("Debug")]
    public bool debugCurrentAcceleration;
    public bool debugGrounding;
    public bool debugMoveState;
    public bool debugGravityForce;
    public bool debugAbleToStand;

    //External References
    private CustomControls playerControls;
    private CharacterController playerCharacterController;

    //External Referrables
    [HideInInspector]
    public bool playerGrounded;
    [HideInInspector]
    public bool playerCrouching;            // Crouching
    [HideInInspector]
    public bool playerMoving;           //Is the player moving? Omits Vertical Movement
    [HideInInspector]
    public float totalSpeed;

    //Private Value Storage
    private float originalYExtents;
    private float currentAcceleration;
    private float currentYVelocity;
    private bool playerCrouchToggleState;   // Crouching | Only used with toggle crouching (True while crouching)


    //Initializing external references and initial values
    private void Start()
    {
        currentYVelocity = staticGravityStrength;
        playerControls = gameObject.GetComponent<CustomControls>();
        playerCharacterController = gameObject.GetComponent<CharacterController>();
        currentAcceleration = 1;
        originalYExtents = transform.GetComponent<Collider>().bounds.extents.y;
    }


    //Calling primary methods
    private void Update()
    {
        PlayerGroundUpdate();
        PlayerGravityUpdate();
        PlayerJumpUpdate();
        PlayerMoveCheck();
        PlayerAccelerationUpdate();
        MoveFunction();
        PlayerCrouchUpdate();
        PlayerCrouchStateUpdate();
    }


    //DONE
    //Gets user input and applies movement to the character
    private void MoveFunction()
    {
        Vector3 playerMovementInput = Vector3.zero;

        bool playerForwardInput = Input.GetKey(playerControls.forwardKey);
        bool playerBackInput = Input.GetKey(playerControls.backKey);
        bool playerRightInput = Input.GetKey(playerControls.rightKey);
        bool playerLeftInput = Input.GetKey(playerControls.leftKey);

        float directionSpeedScaleValue = 1;

        if (playerForwardInput && !playerBackInput)
        {
            playerMovementInput.z = 1;
        }
        else if (playerBackInput && !playerForwardInput)
        {
            playerMovementInput.z = -1;
            if (!playerRightInput && !playerLeftInput)
            {
                directionSpeedScaleValue = playerBackWalkSpeedDivider;
            }
        }

        void ModulateDiagonalSpeedScale()
        {
            if (!playerBackInput && !playerForwardInput)
            {
                directionSpeedScaleValue = playerSideWalkSpeedDivider;
            }
            else
            {
                if (playerForwardInput)
                {
                    directionSpeedScaleValue = playerForwardDiagonalWalkSpeedDivider;
                }
                else
                {
                    directionSpeedScaleValue = playerBackDiagonalWalkSpeedDivider;
                }
            }
        }

        if (playerRightInput && !playerLeftInput)
        {
            playerMovementInput.x = 1;
            ModulateDiagonalSpeedScale();
        }
        else if (playerLeftInput && !playerRightInput)
        {
            playerMovementInput.x = -1;
            ModulateDiagonalSpeedScale();
        }

        playerMovementInput.Normalize();
        playerMovementInput /= directionSpeedScaleValue;

        totalSpeed = baseWalkSpeed * currentAcceleration;
        Vector3 playerMovement = playerMovementInput * totalSpeed * Time.deltaTime;

        if (playerCrouching)
        {
            playerMovement /= crouchSpeedDivider;
        }

        playerMovement.y = currentYVelocity * Time.deltaTime;

        playerMovement = transform.TransformDirection(playerMovement);

        playerCharacterController.Move(playerMovement);
    }


    //DONE
    //Updating the player movement state | Omits Vertical Movement
    private Vector3 previousPosition;
    private void PlayerMoveCheck()
    {
        //Calculating displacement and comparing to move check tolerance
        Vector3 currentPosition = transform.position;
        currentPosition.y = 0;
        float displacement = (previousPosition - currentPosition).magnitude;
        previousPosition = currentPosition;
        playerMoving = displacement > moveCheckTolerance;

        //DEBUG ***
        if (debugMoveState)
        {
            print("PLAYER MOVING: " + playerMoving);
        }
    }


    //DONE
    //Gets user input and updates the current acceleration value
    private void PlayerAccelerationUpdate()
    {
        // Setting accelerationt 1 while standing still
        if (!playerMoving && playerGrounded)
        {
            currentAcceleration = 1;
        }
        //Acceleration Below
        else if (Input.GetKey(playerControls.sprintKey) && playerMoving && playerGrounded && !playerCrouching)
        {
            if (currentAcceleration < maxAccelerationMultiplier)
            {
                float newAcceleration = currentAcceleration + (Time.deltaTime * accelerationRate);
                if (newAcceleration < maxAccelerationMultiplier)
                {
                    currentAcceleration = newAcceleration;
                }
                else
                {
                    currentAcceleration = maxAccelerationMultiplier;
                }
            }
        }
        //Deacceleration Below
        else if (playerGrounded)
        {
            float newAcceleration = currentAcceleration - (Time.deltaTime * deaccelerationRate);
            if (newAcceleration <= 1)
            {
                currentAcceleration = 1;
            }
            else
            {
                currentAcceleration = newAcceleration;
            }
        }

        //DEBUG ***
        if (debugCurrentAcceleration)
        {
            print("CURRENT ACCELERATION: " + currentAcceleration);
        }
    }


    //DONE
    //Updates the current ground bool of the player
    private void PlayerGroundUpdate()
    {
        playerGrounded = playerCharacterController.isGrounded;

        //DEBUG ***
        if (debugGrounding)
        {
            print("CURRENTLY GROUNDED: " + playerGrounded);
        }
    }


    //DONE
    //Updates Gravity Force
    private void PlayerGravityUpdate()
    {
        if (playerGrounded)
        {
            currentYVelocity = -staticGravityStrength;
        }
        else
        {
            currentYVelocity -= Time.deltaTime * gravityForce;
        }


        //DEBUG ***
        if (debugGravityForce)
        {
            print(currentYVelocity);
        }
    }


    //DONE
    //Adjusts the current jump value
    private void PlayerJumpUpdate()
    {
        if (playerGrounded)
        {
            if (Input.GetKeyDown(playerControls.jumpKey))
            {
                currentYVelocity = jumpStrength;
            }
        }
    }


    //DONE
    //Updates the player crouching
    private void PlayerCrouchUpdate()
    {
        if (!playerGrounded)
        {
            return;
        }

        void StandScaleModulation()
        {
            if (transform.localScale.y < maxYScale)
            {
                if (PlayerStandCheck())
                {
                    float previousExtents = transform.GetComponent<Collider>().bounds.extents.y;
                    //Scaling player Up
                    float newScale = transform.localScale.y + standRate * Time.deltaTime;
                    Vector3 scaleVector = transform.localScale;
                    if (newScale > maxYScale)
                    {
                        scaleVector.y = maxYScale;
                    }
                    else
                    {
                        scaleVector.y = newScale;
                    }

                    float newExtents = originalYExtents * scaleVector.y;
                    float heightShift = newExtents - previousExtents;
                    transform.localScale = scaleVector;
                    transform.position += Vector3.up * heightShift;
                }
            }
        }

        void CrouchScaleModulation()
        {
            if (transform.localScale.y > minYScale)
            {
                float previousExtents = transform.GetComponent<Collider>().bounds.extents.y;
                //Scaling Player Down
                float newScale = transform.localScale.y - crouchRate * Time.deltaTime;
                Vector3 scaleVector = transform.localScale;
                if (newScale < minYScale)
                {
                    scaleVector.y = minYScale;
                }
                else
                {
                    scaleVector.y = newScale;
                }

                float newExtents = originalYExtents * scaleVector.y;
                float heightShift = previousExtents - newExtents;
                transform.localScale = scaleVector;
                transform.position += Vector3.down * heightShift;
            }
        }


        //Toggle Crouch
        if (playerControls.toggleCrouch)
        {
            //Toggling crouch state
            if (Input.GetKeyDown(playerControls.crouchKey))
            {
                playerCrouchToggleState = !playerCrouchToggleState;
            }

            //Crouching
            if (playerCrouchToggleState)
            {
                CrouchScaleModulation();
            }
            //Not Crouching
            else
            {
                StandScaleModulation();
            }

            //Hold to crouch
        }
        else
        {
            if (Input.GetKey(playerControls.crouchKey))
            {
                //Crouching
                CrouchScaleModulation();
            }
            else
            {
                //Not Crouching
                StandScaleModulation();
            }
        }
    }


    //DONE
    //Updates the player crouching bool
    private void PlayerCrouchStateUpdate()
    {
        playerCrouching = transform.localScale.y < maxYScale;
    }


    //DONE
    //Updates the ability of the player to stand
    private bool PlayerStandCheck()
    {
        Vector3 origin = gameObject.transform.position;
        float yExtents = gameObject.GetComponent<Collider>().bounds.extents.y;
        float xExtents = gameObject.GetComponent<Collider>().bounds.extents.x;
        origin.y += yExtents;
        origin.y -= xExtents;

        bool hit = Physics.SphereCast(origin, xExtents, Vector3.up, out _, playerStandCheckTolerance + xExtents / 2);

        //DEBUG ***
        if (debugAbleToStand)
        {
            print("ABLE TO STAND: " + !hit);
        }

        return !hit;
    }
}