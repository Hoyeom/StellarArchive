using Cysharp.Threading.Tasks;

namespace StellarArchive
{
    internal interface IActivationHandler
    {
        internal UniTask<bool> OnTryCloseAsync(string key);
        internal UniTask<bool> OnTryOpenAsync(string key);
    }
}
