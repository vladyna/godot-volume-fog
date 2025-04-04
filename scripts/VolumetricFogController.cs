using Godot;
using Godot.Collections;

namespace VolumetricFog
{
    public partial class VolumetricFogController : Node3D
    {
        #region Exposed Dependencies
        [Export] public ShaderMaterial FogMaterial;
        [Export] public int MaxLights = 8;
        [Export] public Array<OmniLight3D> _lights;
        [Export] private float _maxFogDensity = 5f;
        [Export] private float _fogSpread = 0f;
        [Export] private FogVolume _fogVolume;
        #endregion

        #region Private Variables
        private Vector3[] _lightArray;
        private float[] _lightRadiuses;
        private Vector3[] _lightColors;
        #endregion

        #region Godot's Methods
        public override void _Ready()
        {
            if (FogMaterial == null)
                return;
            Initialize();
        }
        public override void _Process(double delta)
        {
            UpdateFog();
        }
        #endregion

        #region Public Methods
        public void AddOmniLight(OmniLight3D light)
        {
            if (_lights.Count < MaxLights)
            {
                _lights.Add(light);
            }
            else
            {
                GD.PushWarning("Cannot add more lights maximum amount reached");
            }
        }
        public void RemoveOmniLight(OmniLight3D light)
        {
            if (_lights.Contains(light))
            {
                _lights.Remove(light);
            }
        }
        #endregion

        #region Private Methods 
        private void Initialize()
        {
            _lightArray = new Vector3[MaxLights];
            _lightRadiuses = new float[MaxLights];
            _lightColors = new Vector3[MaxLights];

            FogMaterial.SetShaderParameter("spread_progress", 0);

            UpdateFogShaderLights();
        }

        private void UpdateFog()
        {
            if (FogMaterial == null)
                return;

            UpdateFogShaderLights();
            FogMaterial.SetShaderParameter("spread_progress", _fogSpread);
        }

        private void UpdateFogShaderLights()
        {

            for (int i = 0; i < _lights.Count; i++)
            {
                if (i < _lights.Count)
                {
                    var light = _lights[i];
                    var color = light.LightColor;
                    _lightArray[i] = light.GlobalPosition;
                    _lightRadiuses[i] = light.OmniRange * 4;
                    _lightColors[i] = new Vector3(color.R, color.G, color.B);
                }

            }

            FogMaterial.SetShaderParameter("light_positions", _lightArray);
            FogMaterial.SetShaderParameter("light_count", _lights.Count);
            FogMaterial.SetShaderParameter("light_radiuses", _lightRadiuses);
            FogMaterial.SetShaderParameter("light_colors", _lightColors);
            FogMaterial.SetShaderParameter("fog_size", GetVolumeLongsetSide());
        }

        private float GetVolumeLongsetSide()
        {
            var size = _fogVolume.Size;
            return size.X > size.Y ? size.X > size.Z ? size.X : size.Z : size.Y > size.Z ? size.Y : size.Z;
        }
        #endregion

    }
}