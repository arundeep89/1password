Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

## Funnel:

```mermaid
flowchart LR
    %% Phase 1: Suggestion
    subgraph Phase_1 [Suggestion Phase]
        S1[passkey-suggestion-shown]
        S2[passkey-suggestion-dismissed]
        S3[passkey-suggestion-accepted]
        
        S1 -- "Negative Outcome" --> S2
        S1 -- "Intent to Register" --> S3
    end

    %% Phase 2: Registration
    subgraph Phase_2 [Registration Phase]
        R1[passkey-save-success]
        R2[passkey-save-failure_*]
        
        S3 -- "Credential Created" --> R1
        S3 -- "Registration Error" --> R2
    end

    %% Phase 3: Usage
    subgraph Phase_3 [Usage Phase]
        U1[passkey-fill-success]
        U2[passkey-fill-failure_*]
        
        R1 -- "Active Use" --> U1
        R1 -- "Usage Error" --> U2
    end

    %% Happy Path (positive signals in green)
    classDef happyPath fill:#d4edda,stroke:#28a745,stroke-width:3px,color:#000
    class S1,S3,R1,U1 happyPath
    
    %% Styling for negative outcomes
    style S2 fill:#f8d7da,stroke:#dc3545,stroke-width:2px,color:#000
    style R2 fill:#f8d7da,stroke:#dc3545,stroke-width:2px,color:#000
    style U2 fill:#f8d7da,stroke:#dc3545,stroke-width:2px,color:#000
 ```   
