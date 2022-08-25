using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
    [Header("Referenced GameObjects")]
    public Transform player;
    private CustomControls playerControls;

    private float xAxisClamp;
    [HideInInspector]

    //METHOD INITIALIZATION AND UPDATE
    private void Start()
    {
        playerControls = gameObject.GetComponentInParent<CustomControls>();
        xAxisClamp = 0.0f;
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        CameraRotation();
    }

    //DONE
    private void CameraRotation()
    {
        float mouseX = Input.GetAxisRaw("Mouse X") * playerControls.mouseSensitivity * Time.deltaTime;
        float mouseY = Input.GetAxisRaw("Mouse Y") * playerControls.mouseSensitivity * Time.deltaTime;

        if (playerControls.invertMouseX)
        {
            mouseX = -mouseX;
        }
        if (playerControls.invertMouseY)
        {
            mouseY = -mouseY;
        }

        xAxisClamp += mouseY;

        if (xAxisClamp > 90.0f)
        {
            xAxisClamp = 90.0f;
            mouseY = 0.0f;
            ClampXAxisRotationToValue(270.0f);
        }
        else if (xAxisClamp < -90.0f)
        {
            xAxisClamp = -90.0f;
            mouseY = 0.0f;
            ClampXAxisRotationToValue(90.0f);
        }

        transform.Rotate(Vector3.left * mouseY);
        player.Rotate(Vector3.up * mouseX);
    }

    //DONE
    private void ClampXAxisRotationToValue(float value)
    {
        Vector3 eulerRotation = transform.eulerAngles;
        eulerRotation.x = value;
        transform.eulerAngles = eulerRotation;
    }
}


