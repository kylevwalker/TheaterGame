using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hazardous : MonoBehaviour
{
    public int damage;
    private PlayerHealth playerHealth;

    void Start()
    {
        playerHealth = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerHealth>();
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.CompareTag("Player"))
        {
            playerHealth.TakeDamage(damage);
            
        }
      
    }
}
