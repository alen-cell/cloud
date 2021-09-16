using System.Collections;
using System.Collections.Generic;
using UnityEngine;






  [ExecuteInEditMode]

public class CloudGenerator : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");


    [SerializeField,Range(0,10)]
    int pow = 2;

    

    //public Transform prefab;
    public int instanceCount = 50;
    public float scale = 10f;
    public Material instanceMat;
    public Mesh instanceMesh;
    Matrix4x4[] matrices;
    Vector4[] colors;

    public float[] offsets;
   
    MaterialPropertyBlock block;
    LightShadowCasterMode castShadows;
    public float High; 
    
    void BuildMatrixAndBlock()
    {
        
        block = new MaterialPropertyBlock();
        colors = new Vector4[instanceCount];
        float[] Alpha_clip = new float[instanceCount];
        matrices = new Matrix4x4[instanceCount];
        for(int i= 0;i < instanceCount; i++)
        {
            float Count = instanceCount;
            colors[i] = new Vector4(Random.value, Random.value, Random.value, 1f);//Color.white * i / Count;
            offsets[i] = i* High / Count;
            Alpha_clip[i] = Mathf.Pow(i/Count*2 - 1,pow);
            matrices[i] = Matrix4x4.TRS(new Vector3(offsets[i], 0, 0), Quaternion.identity, Vector3.one); 


        }

       
        
}
    // Start is called before the first frame update
    void Start()
    {
        BuildMatrixAndBlock();
        var support = SystemInfo.supportsInstancing;
        Debug.Log("Instance rendering"+ support);

    }

    // Update is called once per frame
    void Update()
    {
        if(block == null)
        {
            block = new MaterialPropertyBlock();
        block.SetVectorArray(baseColorId, colors);
        }
        
        Graphics.DrawMeshInstanced(instanceMesh, 0, instanceMat, matrices, 20);
    }
}
