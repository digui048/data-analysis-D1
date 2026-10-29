using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using UnityEngine.Networking;

public class DatabaseSend : MonoBehaviour
{
    // folder server
    [SerializeField] private string serverURL = "https://citmalumnes.upc.es/~mariomr2/server/Sending/";

    [SerializeField] private int maxRetries = 3;
    [SerializeField] private float retryDelay = 1.0f;

    #region Setup
    
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void CreateOnStart()
    {
        if (FindFirstObjectByType<Simulator>() != null)
        {
            new GameObject("DatabaseSend").AddComponent<DatabaseSend>();
        }
    }

    #endregion

    #region Subscribe

    private void OnEnable()
    {
        Simulator.OnNewPlayer += CreateUser;
        Simulator.OnNewSession += StartSession;
        Simulator.OnEndSession += EndSession;
        Simulator.OnBuyItem += BuyItem;
    }

    private void OnDisable()
    {
        Simulator.OnNewPlayer -= CreateUser;
        Simulator.OnNewSession -= StartSession;
        Simulator.OnEndSession -= EndSession;
        Simulator.OnBuyItem -= BuyItem;
    }

    #endregion

    #region Events

    // new user
    private void CreateUser(string name, string country, int age, float gender, DateTime date)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "name", name },
            { "country", country },
            { "age", age.ToString() },
            { "gender", gender.ToString(CultureInfo.InvariantCulture) },
            { "date", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("CreateUser.php", data, (userID) =>
        {
            CallbackEvents.OnAddPlayerCallback?.Invoke(userID);
        }));
    }

    // save session
    private void StartSession(DateTime date, uint userID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "userID", userID.ToString() },
            { "start", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("StartSession.php", data, (sessionID) =>
        {
            CallbackEvents.OnNewSessionCallback?.Invoke(sessionID);
        }));
    }

    // save purchase
    private void BuyItem(int itemID, DateTime date, uint sessionID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "sessionID", sessionID.ToString() },
            { "itemID", itemID.ToString() },
            { "date", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("BuyItem.php", data, (returnedSessionID) =>
        {
            CallbackEvents.OnItemBuyCallback?.Invoke(returnedSessionID);
        }));
    }

    // close session
    private void EndSession(DateTime date, uint sessionID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "sessionID", sessionID.ToString() },
            { "end", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("EndSession.php", data, (userID) =>
        {
            CallbackEvents.OnEndSessionCallback?.Invoke(userID);
        }));
    }

    #endregion

    #region Sending

    // send data to phpp
    private IEnumerator SendDataToServer(string phpFile, Dictionary<string, string> data, Action<uint> callback)
    {
        string url = serverURL + phpFile;

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            WWWForm form = new WWWForm();
            foreach (KeyValuePair<string, string> entry in data)
            {
                form.AddField(entry.Key, entry.Value);
            }

            using (UnityWebRequest request = UnityWebRequest.Post(url, form))
            {
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    string response = request.downloadHandler.text.Trim();

                    if (uint.TryParse(response, out uint id))
                    {
                        callback?.Invoke(id);
                    }
                    else
                    {
                        Debug.LogError($"{phpFile} answered: {response}");
                    }
                    yield break;
                }

                Debug.LogWarning($"Connection error sending to {phpFile} (attempt {attempt}/{maxRetries}): {request.error}");
            }

            yield return new WaitForSeconds(retryDelay);
        }

        Debug.LogError($"Could not send data to {phpFile} after {maxRetries} attempts.");
    }

    // date format
    private string FormatDate(DateTime date)
    {
        return date.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
    }

    #endregion
}
