using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomControls : MonoBehaviour
{
    [Header("Movement Controls")]
    public KeyCode forwardKey;
    public KeyCode backKey;
    public KeyCode leftKey;
    public KeyCode rightKey;
    public KeyCode sprintKey;
    public KeyCode jumpKey;
    public KeyCode crouchKey;
    public bool toggleCrouch;

    [Header("View Controls")]
    public float mouseSensitivity;
    public bool invertMouseX;
    public bool invertMouseY;

    [Header("Gameplay Controls")]
    public KeyCode interactionKey;
    public KeyCode inventoryKey;
    public KeyCode primaryKey;
    public KeyCode secondaryKey;
}
