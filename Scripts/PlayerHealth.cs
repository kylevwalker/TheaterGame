using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHealth : MonoBehaviour
{
    public int maxHealth = 5;
    public int currentHealth;
    public HealthDisplay healthBar;
    public PlayerPlatforming player;


    // Start is called before the first frame update
    void Start()
    {
        currentHealth = maxHealth;
        healthBar.healthValText.text = currentHealth.ToString();
    }

    public void TakeDamage(int damage)
    {
        currentHealth -= damage;
        player.TakeDamageTrigger();
        
        // Hurt Anim
        if (currentHealth <= 0)
        {
            currentHealth = 0;
            Die();
        }
        healthBar.healthValText.text = currentHealth.ToString();
    }
    
    void Die()
    {
        //play Death anim
        // Disable controls
        print("You are dead");
    }

}
